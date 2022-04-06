pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Cosmite is ERC20 {
    constructor() ERC20("Cosmite", "CMT"){
        _mint(msg.sender, 10**18);
    }
}