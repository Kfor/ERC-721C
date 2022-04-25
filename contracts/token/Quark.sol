// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721Q.sol";

contract Quark is ERC721Q, ReentrancyGuard {
  constructor(
    string memory name_,
    string memory symbol_,
    uint256 layerCount,
    uint256 collectionSize_
  ) ERC721Q(name_, symbol_, layerCount, collectionSize_) {}

  string private _contractURI;

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function setContractURI(string calldata contractURI) external onlyOwner {
    _contractURI = contractURI;
  }

  // metadata URI
  string private _baseTokenURI;

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function withdraw() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }
}