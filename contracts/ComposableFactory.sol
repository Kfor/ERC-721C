import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IERC721C.sol";
import "hardhat/console.sol";

contract ComposableFactory is IERC721Receiver {
    // C address => (CID => QID), store the relation between Q and C
    mapping(address => mapping(uint256 => uint256[30])) CToQMapping;
    // Q address => C address, used to find the C address by Q address
    mapping(address => address) QToCAddressMapping;
    // C address => Q address
    mapping(address => address) CToQAddressMapping;

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function addQToCAddressMapping(address quark, address erc721c) external returns(bool) {
        QToCAddressMapping[quark] = erc721c;
        CToQAddressMapping[erc721c] = quark;
        return true;
    }


    function quarksOf(address erc721c, uint256 cId) external view returns(uint256[30] memory) {
        return CToQMapping[erc721c][cId];
    }

    function addCIdToQuarksMapping(address erc721q, uint256 cId, uint256[30] memory qIds) external {
        require(QToCAddressMapping[erc721q] == msg.sender, "can only add mapping by the C contract");
        CToQMapping[msg.sender][cId] = qIds;
    }

    function compose(address erc721q, uint256[] memory qIds) external {
        address erc721c = QToCAddressMapping[erc721q];
        uint256 layerCount = IERC721C(erc721c).getLayerCount();
        bool[30] memory appeared;

        require(qIds.length <= layerCount, "qIds length must less than layerCount");
        for(uint256 i = 0; i < qIds.length; i++) {
            require(!appeared[qIds[i] % layerCount], "qs cannot be in one layer");
            appeared[qIds[i] % layerCount] = true;
            // promise the target quark is owned by msg.sender, and transfer
            IERC721(erc721q).transferFrom(msg.sender, address(this), qIds[i]);
        }
        // mint the composed c to msg.sender
        uint256 newCId = IERC721C(erc721c).poolMint(msg.sender);
        uint256[30] memory tmpQIds;
        for(uint256 i = 0; i < qIds.length; i++) {
            tmpQIds[i] = qIds[i];
        }
        CToQMapping[erc721c][newCId] = tmpQIds;
    }

    function split(address erc721c, uint256 cId) external {
        require(IERC721(erc721c).ownerOf(cId) == msg.sender, "you must have this ERC721C to split");
        require(CToQMapping[erc721c][cId].length > 0, "can't split a composed ERC721C");
        IERC721(erc721c).transferFrom(msg.sender, address(this), cId);
        uint256[30] memory qIds = CToQMapping[erc721c][cId];
        address erc721q = CToQAddressMapping[erc721c];
        for(uint256 i = 0; i < IERC721C(erc721c).getLayerCount(); i++) {
            IERC721(erc721q).transferFrom(address(this), msg.sender, qIds[i]);
        }
        delete CToQMapping[erc721c][cId];
    }
}