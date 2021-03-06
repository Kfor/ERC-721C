// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721C {
    function getLayerCount() external view returns(uint8);
    function getQuarkAddress() external view returns (address);
    function totalCount() external view returns (uint256);
    function poolMint(address to) external returns(uint256);
    function burn(address tokenOwner, uint256 tokenId) external;
}