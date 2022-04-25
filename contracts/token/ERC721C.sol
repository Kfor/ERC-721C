//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "../interface/IComposableFactory.sol";
import "./Quark.sol";
import "./IERC721C.sol";
import "./ERC721A.sol";

contract ERC721C is  
  ERC721A,
  IERC721C{

  // current number of public mint
  uint256 private currentUserMintNum = 0;

  // MAX value of uint256
  uint256 private MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

  // quark contract address
  address private _quarkAddress = address(0);

  // layer count
  uint8 private _layerCount;

  // pool address
  address private composableFactoryAddress = address(0);

  uint256 private _currentCount = 0;

  /**
   * @dev
   * `maxBatchSize` refers to how much a minter can mint at a time.
   * `collectionSize_` refers to how many tokens are in the collection.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    uint256 maxBatchSize_,
    uint256 collectionSize_,
    uint8 layerCount_,
    address composableFactoryAddress_
  ) ERC721A(name_, symbol_, maxBatchSize_, collectionSize_){
    require(
      collectionSize_ > 0,
      "collection must have a nonzero supply"
    );
    require(maxBatchSize_ > 0, "max batch size must be nonzero");
    _layerCount = layerCount_;
    _quarkAddress = address(new Quark(name_, symbol_, layerCount_, uint256(layerCount_) * collectionSize_));
    require(IComposableFactory(composableFactoryAddress_).addQToCAddressMapping(_quarkAddress, address(this)),"Join the Pool Failed.");
    composableFactoryAddress = composableFactoryAddress_;
  }

  function getLayerCount() external view override returns (uint8) {
      return _layerCount;
  }

  function _getLayerCount() internal view returns (uint8) {
    return _layerCount;
  }

  function getQuarkAddress() external view override returns (address) {
    return _quarkAddress;
  }

  function _getQuarkAddress() internal view returns (address) {
    return _quarkAddress;
  }

  function _getCurrentUserMintNum() internal view returns (uint256) {
    return currentUserMintNum;
  }

  function burn(address tokenOwner, uint256 tokenId) external override {
    require(msg.sender == composableFactoryAddress, "only factory can burn"); 
    address prevOwnership = ownershipOf(tokenId);
    bool isApprovedOrOwner = (tokenOwner == prevOwnership
    && (getApproved(tokenId) == tokenOwner || isApprovedForAll(prevOwnership, composableFactoryAddress)));

    require(isApprovedOrOwner, "caller is not approved or not owner");
    // Clear approvals
    _approve(address(0), tokenId, prevOwnership);
    AddressData memory addressData = _addressData[tokenOwner];
    _addressData[tokenOwner] = AddressData(
      addressData.balance - 1,
      addressData.numberMinted
    );
    _currentCount -= 1;
    _ownerships[tokenId] = address(0);
    emit Transfer(tokenOwner, address(0), tokenId);
  }

  function totalCount() public view override returns (uint256) {
    return _currentCount;
  }

  function poolMint(address to) external override returns(uint256) {
    require(composableFactoryAddress == msg.sender, "Pool Mint need a Binding Pool");
    require(to != address(0), "mint to the zero address");
    // We know if the first token in the batch doesn't exist, the other ones don't as well, because of serial ordering.
    uint256 startTokenId = currentIndex;
    require(!_exists(startTokenId), "token already minted");
    require(_quarkAddress != address(0),"Quark not bind");

    _beforeTokenTransfers(address(0), to, startTokenId, 1);

    AddressData memory addressData = _addressData[to];
    _addressData[to] = AddressData(
      addressData.balance + uint128(1),
      addressData.numberMinted
    );
    _ownerships[startTokenId] = to;

    emit Transfer(address(0), to, startTokenId);
    require(
      _checkOnERC721Received(address(0), to, currentIndex, ""),
      "transfer to non ERC721Receiver implementer"
    );
    currentIndex++;
    _currentCount++;
    _afterTokenTransfers(address(0), to, startTokenId, 1);
    return startTokenId;
  }

  /**
   * @dev Mints `quantity` tokens and transfers them to `to`.
   *
   * Requirements:
   *
   * - there must be `quantity` tokens remaining unminted in the total collection.
   * - `to` cannot be the zero address.
   * - `quantity` cannot be larger than the max batch size.
   *
   * Emits a {Transfer} event.
   */
  function _safeMint(
    address to,
    uint256 quantity,
    bytes memory _data
  ) internal override {
    uint256 startTokenId = currentIndex;
    require(to != address(0), "mint to the zero address");
    // We know if the first token in the batch doesn't exist, the other ones don't as well, because of serial ordering.
    require(!_exists(startTokenId), "token already minted");
    require(quantity <= maxBatchSize, "quantity to mint too high");
    require(_quarkAddress != address(0),"Quark not bind");

    _beforeTokenTransfers(address(0), to, startTokenId, quantity);

    AddressData memory addressData = _addressData[to];
    _addressData[to] = AddressData(
      addressData.balance + uint128(quantity),
      addressData.numberMinted + uint128(quantity)
    );
    _ownerships[startTokenId] = to;

    uint256 updatedIndex = startTokenId;

    require(composableFactoryAddress != address(0), "must join the pool before mint");
    for (uint256 i = 0; i < quantity; i++) {
      // mint Quarks, add mapping
      uint256 startQuarkIndex = Quark(_quarkAddress).cMint(composableFactoryAddress, _layerCount);
      uint256[] memory tokenIds = new uint256[](_layerCount);
      for(uint8 j = 0; j < _layerCount; j++) {
        tokenIds[j] = startQuarkIndex + j;
      }
      IComposableFactory(composableFactoryAddress).addCIdToQuarksMapping(_quarkAddress, updatedIndex, tokenIds);
      emit Transfer(address(0), to, updatedIndex);
      require(
        _checkOnERC721Received(address(0), to, updatedIndex, _data),
        "transfer to non ERC721Receiver implementer"
      );
      updatedIndex++;
      currentUserMintNum++;
    }

    currentIndex = updatedIndex;
    _currentCount += quantity;
    _afterTokenTransfers(address(0), to, startTokenId, quantity);
  }
}
