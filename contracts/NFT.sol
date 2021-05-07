// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract NFT is ERC721 {
  constructor() {
  }

  function balanceOf(address _owner) public override view returns (uint256) {
    // TODO
  }

  function ownerOf(uint256 _tokenId) public override view returns (address) {
    // TODO
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) public override payable {
    // TODO
  }


  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override payable {
    // TODO
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public override payable {
    // TODO
  }

  function approve(address _approved, uint256 _tokenId) public override payable {
    // TODO
  }

  function setApprovalForAll(address _operator, bool _approved) public override {
    // TODO
  }

  function getApproved(uint256 _tokenId) public override view returns (address) {
    // TODO
  }

  function isApprovedForAll(address _owner, address _operator) public override view returns (bool) {
    // TODO
  }
}
