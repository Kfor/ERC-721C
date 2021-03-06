//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./token/IERC721C.sol";
import "hardhat/console.sol";

contract ComposableFactory is IERC721Receiver {
    // C address => (CID => QID), store the relation between Q and C
    mapping(address => mapping(uint256 => uint256[])) CToQMapping;
    // Q address => C address, used to find the C address by Q address
    mapping(address => address) QToCAddressMapping;
    // C address => Q address
    mapping(address => address) CToQAddressMapping;

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function addQToCAddressMapping(address quark, address erc721c) external returns(bool) {
        QToCAddressMapping[quark] = erc721c;
        CToQAddressMapping[erc721c] = quark;
        return true;
    }

    function quarksOf(address erc721c, uint256 cId) external view returns(uint256[] memory) {
        // when cId is 0, means related token does not exist
        require(CToQMapping[erc721c][cId].length != 0, "token not exist");
        return CToQMapping[erc721c][cId];
    }

    function addCIdToQuarksMapping(address erc721q, uint256 cId, uint256[] memory qIds) external {
        require(QToCAddressMapping[erc721q] == msg.sender, "can only add mapping by the C contract");
        CToQMapping[msg.sender][cId] = qIds;
    }

    function compose(address erc721q, uint256[] memory qIds) external {
        address erc721c = QToCAddressMapping[erc721q];
        uint256 layerCount = IERC721C(erc721c).getLayerCount();
        bool[] memory appeared = new bool[](layerCount);

        require(qIds.length <= layerCount, "qIds length must be less than layerCount");
        require(qIds.length > 0, "qIds length must be greater than 0");

        for(uint256 i = 0; i < qIds.length; i++) {
            require(!appeared[qIds[i] % layerCount], "qs cannot be in one layer");
            appeared[qIds[i] % layerCount] = true;
            // promise the target quark is owned by msg.sender, and transfer
            IERC721(erc721q).safeTransferFrom(msg.sender, address(this), qIds[i]);
        }
        // mint the composed c to msg.sender
        uint256 newCId = IERC721C(erc721c).poolMint(msg.sender);
        CToQMapping[erc721c][newCId] = qIds;
    }

    function split(address erc721c, uint256 cId) external {
        require(IERC721(erc721c).ownerOf(cId) == msg.sender, "you must have this ERC721C to split");
        IERC721C(erc721c).burn(msg.sender, cId);
        uint256[] memory qIds = CToQMapping[erc721c][cId];
        address erc721q = CToQAddressMapping[erc721c];
        for(uint256 i = 0; i < qIds.length; i++) {
            IERC721(erc721q).safeTransferFrom(address(this), msg.sender, qIds[i]);
        }
        delete CToQMapping[erc721c][cId];
    }
}