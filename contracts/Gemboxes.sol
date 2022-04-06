// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Gemboxes is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    string public name;
    string public symbol;
    mapping(uint256 => string) public collectionsName;
    constructor() ERC1155("") {
        name = "Gemboxes";
        symbol = "Gem";
    }

  function createToken(uint256 amount) public {
    tokenIds.increment();
    uint256 newTokenId = tokenIds.current();
    _mint(msg.sender, newTokenId, amount, "");
    _setURI("");
  }
}
