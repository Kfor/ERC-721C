////SPDX-License-Identifier: Unlicense
//pragma solidity ^0.8.0;
//
//import "./ERC721T.sol";
//interface IERC721C is IERC721 {
//    function deleteChild(address , uint256 , uint256 );
//}
//
//contract ERC721T is ERC721A {
//
//
//
//    address parentAddress;
//    mapping (uint256 => uint256) _tokenParent;
//
//    function transferFrom(address _from, address _to, uint256 _tokenId) external returns (bool _success){
//        _transferT(_from,_to,_tokenId);
//    }
////
////    function _transferT(
////        address from,
////        address to,
////        uint256 tokenId
////    ) private {
////        TokenOwnership memory prevOwnership = ownershipOf(tokenId);
////
////        bool isApprovedOrOwnerOrERC721C = (_msgSender() == prevOwnership.addr ||
////        getApproved(tokenId) == _msgSender() ||
////        isApprovedForAll(prevOwnership.addr, _msgSender()) || _msgSender() == parentAddress);
////
////        if(_msgSender() != parentAddress) {
////            IERC721C(parentAddress).deleteChild(msg.sender, _tokenParent[tokenId], tokenId);
////        }
////
////        require(
////            isApprovedOrOwnerOrERC721C,
////            "ERC721T: transfer caller is not owner nor approved nor erc721c"
////        );
////
////        require(
////            prevOwnership.addr == from,
////            "ERC721T: transfer from incorrect owner"
////        );
////        require(to != address(0), "ERC721A: transfer to the zero address");
////
////        _beforeTokenTransfers(from, to, tokenId, 1);
////
////        // Clear approvals from the previous owner
////        _approve(address(0), tokenId, prevOwnership.addr);
////
////        _addressData[from].balance -= 1;
////        _addressData[to].balance += 1;
////        _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));
////
////        // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
////        // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
////        uint256 nextTokenId = tokenId + 1;
////        if (_ownerships[nextTokenId].addr == address(0)) {
////            if (_exists(nextTokenId)) {
////                _ownerships[nextTokenId] = TokenOwnership(
////                    prevOwnership.addr,
////                    prevOwnership.startTimestamp
////                );
////            }
////        }
////
////        emit Transfer(from, to, tokenId);
////        _afterTokenTransfers(from, to, tokenId, 1);
////    }
//}
