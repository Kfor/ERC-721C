import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./token/ERC721C.sol";
import "./token/Quark.sol";

contract ComposablePandas is ERC721C, ReentrancyGuard {

    constructor(string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_,
        uint256 userMintCollectionSize_,
        uint8 layerCount_,
        address composableFactoryAddress_)
    ERC721C(name_,symbol_,maxBatchSize_,userMintCollectionSize_,layerCount_,composableFactoryAddress_) {}

    uint256 private _currentPublicMintQBatchNum = 0;
    mapping(address => uint256) private _currentPublicMintQBatchNumByUser;

    uint256 private cPublicPrice = 0.05 ether;
    bool private isCPublicMintStart = false;
    bool private isQuarkPublicMintStart = false;

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
        require(isCPublicMintStart, "Composable Pandas: Public Mint C is not started");
        require(_getCurrentUserMintNum() + quantity <= 1000, "Composable Pandas: You have reached the maximum number of mints");
        require(quantity + _numberMinted(msg.sender) <= 2, "Composable Pandas: Only 2 Composable Pandas can be minted");
        require(cPublicPrice * quantity <= msg.value, "Composable Pandas: Not enough ETH");
        _safeMint(msg.sender, quantity);
        refundIfOver(cPublicPrice * quantity);
    }

    function publicMintBatchQ(uint256 cQuantity) public {
        require(isQuarkPublicMintStart, "Composable Pandas: Public Mint Q is not started");
        require(_currentPublicMintQBatchNum + cQuantity <= 1000,
            "Composable Pandas: You have reached the maximum number of mints");
        require(cQuantity + _currentPublicMintQBatchNumByUser[msg.sender] <= 2,
            "Composable Pandas: Only 2 batch of Quarks can be minted");
        Quark(_getQuarkAddress()).mint(msg.sender, cQuantity * _getLayerCount());
        _currentPublicMintQBatchNum += cQuantity;
        _currentPublicMintQBatchNumByUser[msg.sender] += cQuantity;
    }

    function reserveMintBatchQ(uint256 cQuantity) public onlyOwner {
        Quark(_getQuarkAddress()).mint(msg.sender, cQuantity * _getLayerCount());
    }

    function reserveMint(uint256 quantity) public onlyOwner {
        _safeMint(msg.sender, quantity);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
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
        _withdrawQuarkToC();
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Composable Pandas: Transfer failed.");
    }

    function _withdrawQuarkToC() private nonReentrant {
        Quark(_getQuarkAddress()).withdraw();
    }
}