// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721Q.sol";

contract Quark is ERC721Q, ReentrancyGuard, Ownable {
  constructor(
    string memory name_,
    string memory symbol_,
    uint256 layerCount,
    uint256 collectionSize_
  ) ERC721Q(name_, symbol_, layerCount, collectionSize_) {}

  string private _contractURI;

  function mint(address to, uint256 quantity) public onlyOwner {
    _safeMint(to, quantity);
  }

  function getMintedNumber(address to) public view returns (uint256) {
    return _numberMinted(to);
  }

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

  function cMint(address to, uint256 quantity) external onlyOwner returns(uint256)  {
    require(
      totalSupply() + quantity <= collectionSize,
      "Mint Failed: out of collection size range"
    );
    require(
      quantity % maxBatchSize == 0,
      "Mint number should be the multiple of LayerCount"
    );
    uint256 numChunks = quantity / maxBatchSize;
    for (uint256 i = 0; i < numChunks; i++) {
      _safeMint(to, maxBatchSize);
    }
    return currentIndex - quantity;
  }
}