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
    ERC721C(name_,symbol_,layerCount_,collectionSize_,composableFactoryAddress_) {}

    uint256 private _currentPublicMintQBatchNum = 0;
    mapping(address => uint256) private _currentPublicMintQBatchNumByUser;

    uint256 private cPublicPrice = 0.05 ether;
    bool private isCPublicMintStart = false;
    bool private isQuarkPublicMintStart = false;
    uint256 private cPublicMintAmount = 200;
    mapping(address => bool) private _cAddressAppeared;
    mapping(address => uint256) private _cAddressStock;

    function setIsCPublicMintStart(bool isStart) public onlyOwner {
        isCPublicMintStart = isStart;
    }
    function getIsCPublicMintStart() public view returns (bool) {
        return isCPublicMintStart;
    }

    function setIsQuarkPublicMintStart(bool isStart) public onlyOwner {
        isQuarkPublicMintStart = isStart;
    }

    function getIsQuarkPublicMintStart() public view returns (bool) {
        return isQuarkPublicMintStart;
    }

    function publicMintC(uint256 quantity) public payable {
        require(isCPublicMintStart, "not started");
        require(cPublicMintAmount >= quantity, "reached the C maximum");
        if(!_cAddressAppeared[msg.sender]){
            _cAddressAppeared[msg.sender] = true;
            _cAddressStock[msg.sender] = 2;
        }
        require(_cAddressStock[msg.sender] >= quantity, "Only 2 can be minted");
        require(cPublicPrice * quantity <= msg.value, "Not enough");
        for(uint256 i = 0;i < quantity; i++){
            safeMint(msg.sender);
        }
    }

    function publicMintBatchQ(uint256 cQuantity) public {
        require(isQuarkPublicMintStart, "not started");
        require(_currentPublicMintQBatchNum + cQuantity <= 1000,
            "reached the maximum");
        require(cQuantity + _currentPublicMintQBatchNumByUser[msg.sender] <= 2,
            "Only 2 batch can be minted");
        Quark(_getQuarkAddress()).mint(msg.sender, cQuantity * _getLayerCount());
        _currentPublicMintQBatchNum += cQuantity;
        _currentPublicMintQBatchNumByUser[msg.sender] += cQuantity;
    }

    function reserveMintBatchQ(uint256 cQuantity) public onlyOwner {
        Quark(_getQuarkAddress()).mint(msg.sender, cQuantity * _getLayerCount());
    }

    function reserveMint(uint256 quantity) public onlyOwner {
        for(uint256 i = 0;i < quantity;i++){
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
}