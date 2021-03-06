// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./token/ERC721C.sol";
import "./token/Quark.sol";

contract WanderPandas is ERC721C, ReentrancyGuard, Ownable {

    constructor(string memory name_,
        string memory symbol_,
        uint256 collectionSize_,
        uint8 layerCount_,
        address composableFactoryAddress_)
    ERC721C(name_,symbol_,collectionSize_,layerCount_,composableFactoryAddress_) {}

    uint256 private cPublicPrice = 0.5 ether;
    bool public isCPublicMintStart = false;
    bool public isQuarkPublicMintStart = false;
    uint256 private qPublicMintAmount = 6;
    uint256 private cPublicMintAmount = 5;
    mapping(address => bool) private _cAddressAppeared;
    mapping(address => uint256) private _cAddressStock;

    mapping(address => bool) private _qAddressAppeared;
    mapping(address => uint256) private _qAddressStock;

    function setIsCPublicMintStart(bool isStart) public onlyOwner {
        isCPublicMintStart = isStart;
    }

    function setIsQuarkPublicMintStart(bool isStart) public onlyOwner {
        isQuarkPublicMintStart = isStart;
    }

    function publicMintC(uint256 quantity) public payable {
        require(isCPublicMintStart, "not started");
        require(cPublicMintAmount >= quantity, "reached the C maximum");
        if(!_cAddressAppeared[msg.sender]) {
            _cAddressAppeared[msg.sender] = true;
            _cAddressStock[msg.sender] = 2;
        }
        require(_cAddressStock[msg.sender] >= quantity, "Only 2 can be minted");
        require(cPublicPrice * quantity <= msg.value, "Not enough");
        _cAddressStock[msg.sender] -= quantity;
        cPublicMintAmount-=quantity;
        for(uint256 i = 0; i < quantity; i++) {
            safeMint(msg.sender);
        }
    }

    function publicMintBatchQ(uint256 batchQuantity) public {
        require(isQuarkPublicMintStart, "not started");
        require(qPublicMintAmount >= batchQuantity, "reached the Q maximum");
        if(!_qAddressAppeared[msg.sender]) {
            _qAddressAppeared[msg.sender] = true;
            _qAddressStock[msg.sender] = 2;
        }
        require(_qAddressStock[msg.sender] >= batchQuantity, "Only 2 can be minted");
        qPublicMintAmount -= batchQuantity;
        _qAddressStock[msg.sender] -= batchQuantity;
        Quark(_getQuarkAddress()).mint(msg.sender, batchQuantity * _getLayerCount());
    }

    function reserveMintBatchQ(uint256 quantity) public onlyOwner {
        require(qPublicMintAmount >= quantity, "reach the max");
        qPublicMintAmount -= quantity;
        Quark(_getQuarkAddress()).mint(msg.sender, quantity * _getLayerCount());
    }

    function reserveMint(uint256 quantity) public onlyOwner {
        require(cPublicMintAmount >= quantity, "reach the max");
        cPublicMintAmount -= quantity;
        for(uint256 i = 0; i < quantity; i++) {
            safeMint(msg.sender);
        }
    }

    string private _contractURI;

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function setContractURI(string calldata contractURI) public {
        _contractURI = contractURI;
    }

    function setQuarkContractURI(string calldata contractURI) public {
        Quark(_getQuarkAddress()).setContractURI(contractURI);
    }

    // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setQuarkBaseURI(string memory quarkBaseURI) public {
        Quark(_getQuarkAddress()).setBaseURI(quarkBaseURI);
    }

    function withdraw() external onlyOwner nonReentrant {
        Quark(_getQuarkAddress()).withdraw();
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    fallback() payable external  {
    }

    receive() payable external {
    }
}