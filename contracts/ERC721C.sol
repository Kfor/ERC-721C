//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./ERC721T.sol";

contract ERC721C is ERC721T {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_,
        uint256 collectionSize_
    )ERC721T( name_, symbol_, maxBatchSize_, collectionSize_){
    }

    struct TraitData {
        address addr;
        uint256 traitTokenId;
    }

    mapping(uint256 => TraitData[10])  private _childrenTraitMapping;
    uint256 private price;

//    function childTraitFactory() public payable returns (ERC721T) {
//        return new ERC721T("t","ts",100,100);
//    }

    function transferFrom1(address from, address to, uint256 tokenId) public {
        // when transfer erc721c, transfer all the children in the mapping
        require(_exists(tokenId), "token does not exist");
        TraitData[10] storage _traitDataList = _childrenTraitMapping[tokenId];
        for (uint256 i = 0; i < _traitDataList.length; i++) {
            TraitData memory traitData = _traitDataList[i];
            require(IERC721(traitData.addr).ownerOf(traitData.traitTokenId) == msg.sender, "transfer error because you don't have the child trait");
            IERC721(traitData.addr).transferFrom(from, to, traitData.traitTokenId);
        }
        _transfer(from, to, tokenId);
    }

    function deleteChild(address sender, uint256 cId, uint256 tId) external {
        TraitData[10] storage _traitDataList = _childrenTraitMapping[cId];
        for(uint256 i=0;i<_traitDataList.length;i++){
            TraitData memory traitData = _traitDataList[i];
            if (traitData.traitTokenId == tId) {
                require(msg.sender==traitData.addr, "deleteChild from wrong address");
                require(ownerOf(cId)==sender, "user must have the ERC721C");
                delete _traitDataList[tId];
                _childrenTraitMapping[cId] = _traitDataList;
                return;
            }
        }
    }

    TraitData[10] _traitDataList;
    function mint(address[] calldata addressList, uint256[] calldata traitIdList) public payable {
        require(msg.value >= price, "value must be bigger than price");
        _safeMint(msg.sender, 1);
        _childrenTraitMapping[totalSupply()] = _traitDataList;
        for (uint256 i = 0; i < addressList.length; i++) {
            require(IERC721(addressList[i]).ownerOf(traitIdList[i])==msg.sender,"you must have this trait to mint");
            _childrenTraitMapping[totalSupply()][i] = TraitData(addressList[i], traitIdList[i]);
        }
    }

}
