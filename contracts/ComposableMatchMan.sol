import "./ERC721C.sol";

contract ComposableMatchMan is ERC721C {

    constructor(string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_,
        uint256 userMintCollectionSize_,
        uint8 layerCount_) ERC721C(name_,symbol_,maxBatchSize_,userMintCollectionSize_,layerCount_) {}

    function mint() public payable {
        _safeMint(msg.sender, 1);
    }
}