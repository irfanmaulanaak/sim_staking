pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Staking is Ownable{
    using SafeERC20 for IERC20;
    IERC20 public CosmiteAddress;
    address public GemboxesAddress;
    uint256 public totalCosmiteStaked;
    address public platformAddress;
    mapping(address => uint256) public totalStaking;
    mapping(address => uint8) public totalIndex;
    mapping(address => mapping(uint8 => uint256)) public staking;
    mapping(address => bool) public statusMember;
    bool public Initializable;

    event DepositEvent(address userAddress, uint256 amount);
    event HarvestEvent(address userAddress, uint256 DaysPassed, uint256 GemboxTransferred);
    event UnstakingEvent(address userAddress);

    function init(address _cosmiteAddress, address _gemboxesAddress) public onlyOwner {
        require(_cosmiteAddress != address(0) && _gemboxesAddress != address(0), "Address can't null");
        CosmiteAddress = IERC20(_cosmiteAddress);
        GemboxesAddress = _gemboxesAddress;
        Initializable = true;
    }

    function DepositCosmite(uint256 amount) public Initialize{
        require(amount >= 5000, "Please deposit more.");
        CosmiteAddress.safeTransferFrom(msg.sender, address(this), amount);
        totalStaking[msg.sender] = totalStaking[msg.sender] + amount;
        totalIndex[msg.sender]++;
        staking[msg.sender][totalIndex[msg.sender]] = amount;
        totalCosmiteStaked = totalCosmiteStaked + amount;
        if(statusMember[msg.sender] == false){
            statusMember[msg.sender] = true;
        }

        emit DepositEvent(msg.sender, amount);
    }

    function Harvest(uint256 DaysPassed, uint8 index, uint256 tokenID) public Initialize OnlyMember{
        require(DaysPassed > 0, "Please Wait Until Tomorrow");
        require(totalStaking[msg.sender] >= 5000, "You can't harvest right now, please stake more cosmite.");
        uint256 totalHarvestGemboxes = ((staking[msg.sender][index] / 5000) * DaysPassed)/10**18;
        IERC1155(GemboxesAddress).safeTransferFrom(platformAddress, msg.sender, tokenID, totalHarvestGemboxes, "");
        emit HarvestEvent(msg.sender, DaysPassed, totalHarvestGemboxes);
    }

    function HarvestAll(uint256[] memory DaysPassed, uint256 tokenID) public Initialize OnlyMember{
        require(totalStaking[msg.sender] >= 5000, "You can't harvest right now, please stake more cosmite.");
        uint256 totalHarvestGemboxes = 0;
        for (uint8 i = 0; i <= totalIndex[msg.sender]; i++) {
            require(DaysPassed.length == totalIndex[msg.sender], "Mismatch Length totalIndex and DaysPassed!");
            if(DaysPassed[i] == 0){
                revert("DaysPassed is equal to 0!");
            }
            totalHarvestGemboxes = totalHarvestGemboxes + ((staking[msg.sender][i] / 5000) * DaysPassed[i])/10**18;
        }
        IERC1155(GemboxesAddress).safeTransferFrom(platformAddress, msg.sender, tokenID, totalHarvestGemboxes, "");
    }

    function Unstaking(uint256 DaysPassed) public Initialize OnlyMember{
        require(DaysPassed >= 30, "Please wait until 30 Days!");
        for (uint8 i = 0; i <= totalIndex[msg.sender]; i++) {
            delete staking[msg.sender][i];
        }
        totalCosmiteStaked = totalCosmiteStaked - totalStaking[msg.sender];
        CosmiteAddress.safeTransfer(msg.sender, totalStaking[msg.sender]);
        delete totalStaking[msg.sender];
        statusMember[msg.sender] = false;
        emit UnstakingEvent(msg.sender);
    }

    function addPlatform(address newPlatform) public onlyOwner{
        require(newPlatform != address(0), "Address invalid");
        platformAddress = newPlatform;
    }

    function revokePlatform() public onlyOwner{
        delete platformAddress;
    }

    modifier Initialize(){
        require(Initializable == true, "Contract haven't initialized yet.");
        _;
    }
    
    modifier OnlyMember(){
        require(statusMember[msg.sender] == true, "You need to participate in this staking.");
        _;
    }

}