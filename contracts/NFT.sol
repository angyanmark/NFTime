// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ERC721.sol";
import "../interfaces/ERC721TokenReceiver.sol";
import "./utils/AddressUtils.sol";

contract NFT is ERC721 {
  using AddressUtils for address;

  struct Token {
    address owner;
    string URI;
    uint256 price;
  }

  uint256 lastID = 1;

  string constant ZERO_ADDRESS = "Zero address";
  string constant NOT_VALID_NFT = "Not valid NFT";
  string constant NOT_OWNER_APPROVED_OR_OPERATOR = "Not owner approved or operator";
  string constant NOT_OWNER = "Not owner";
  string constant NOT_ABLE_TO_RECEIVE_NFT = "Not able to receive NFT";
  string constant NFT_ALREADY_EXISTS = "NFT already exists";
  string constant NOT_OWNER_OR_OPERATOR = "Not owner or operator";
  string constant IS_OWNER = "Is owner";
  string constant NFT_NOT_FOR_SALE = "NFT not for sale";
  string constant NFT_COSTS_MORE = "NFT costs more";
  string constant PRICE_CANNOT_BE_ZERO = "Price cannot be zero";

  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  mapping(uint256 => Token) public ownerships;

  mapping (uint256 => address) internal idToOwner;
  mapping (uint256 => address) internal idToApproval;
  mapping (address => uint256) private ownerToNFTCount;
  mapping (address => mapping (address => bool)) internal ownerToOperators;

  modifier onlyForSale (uint256 _tokenId) {
    require(
      ownerships[_tokenId].price != 0,
      NFT_NOT_FOR_SALE);
    _;
  }

  modifier onlyOwner(uint256 _tokenId) {
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender,
      NOT_OWNER
    );
    require(
      ownerships[_tokenId].owner == msg.sender,
      NOT_OWNER
    );
    _;
  }

  modifier canOperate(uint256 _tokenId) {
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender ||
      ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_OR_OPERATOR
    );
    _;
  }

  modifier canTransfer(uint256 _tokenId) {
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender ||
      idToApproval[_tokenId] == msg.sender ||
      ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_APPROVED_OR_OPERATOR
    );
    _;
  }

  modifier validNFT(uint256 _tokenId) {
    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    _;
  }

  function balanceOf(address _owner) public override view returns (uint256) {
    require(_owner != address(0), ZERO_ADDRESS);
    return ownerToNFTCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public override view returns (address) {
    address _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);
    return _owner;
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) public override payable {
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override payable {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public override payable
    canTransfer(_tokenId)
    validNFT(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);
    _transfer(_to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) public override payable
    canOperate(_tokenId)
    validNFT(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(_approved != tokenOwner, IS_OWNER);
    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  function setApprovalForAll(address _operator, bool _approved) public override {
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function getApproved(uint256 _tokenId) public override view validNFT(_tokenId) returns (address) {
    return idToApproval[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator) public override view returns (bool) {
    return ownerToOperators[_owner][_operator];
  }

  function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private
    canTransfer(_tokenId)
    validNFT(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);
    _transfer(_to, _tokenId);

    if (_to.isContract())
    {
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
    }
  }

  function _transfer(address _to, uint256 _tokenId) internal {
    address from = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFT(from, _tokenId);
    _addNFT(_to, _tokenId);
    _transferOwnership(_tokenId);
    emit Transfer(from, _to, _tokenId);
  }

  function _transferOwnership(uint256 _tokenId) internal {
    require(ownerships[_tokenId].price != 0, NFT_NOT_FOR_SALE);
    require(msg.value >= ownerships[_tokenId].price, NFT_COSTS_MORE);
    payable(ownerships[_tokenId].owner).transfer(msg.value);
    ownerships[_tokenId].owner = msg.sender;
  }

  function _clearApproval(uint256 _tokenId) private {
    if (idToApproval[_tokenId] != address(0))
    {
      delete idToApproval[_tokenId];
    }
  }

  function _removeNFT(address _from, uint256 _tokenId) internal virtual {
    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    ownerToNFTCount[_from] = ownerToNFTCount[_from] - 1;
    delete idToOwner[_tokenId];
  }

  function _addNFT(address _to, uint256 _tokenId) internal virtual {
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
    idToOwner[_tokenId] = _to;
    ownerToNFTCount[_to] = ownerToNFTCount[_to] + 1;
  }

  function _mint(address _to, uint256 _tokenId, string memory _uri) internal virtual {
    require(_to != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
    _addNFT(_to, _tokenId);
    _addOwnership(_tokenId, _uri);
    emit Transfer(address(0), _to, _tokenId);
  }

  function _addOwnership(uint256 _tokenId, string memory _uri) internal virtual {
    ownerships[_tokenId] = Token(msg.sender, _uri, 0);
  }

  function _burn(uint256 _tokenId) internal virtual
    validNFT(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFT(tokenOwner, _tokenId);
    _removeOwnership(_tokenId);
    emit Transfer(tokenOwner, address(0), _tokenId);
  }

  function _removeOwnership(uint256 _tokenId) internal virtual {
    delete ownerships[_tokenId];
  }

  function mint(string memory _uri) public returns (uint256) {
    _mint(msg.sender, lastID, _uri);
    return lastID++;
  }

  function burn(uint256 _tokenId) public {
    _burn(_tokenId);
  }

  function forSale(uint256 _tokenId, uint256 price) public onlyOwner(_tokenId) {
    require(price != 0, PRICE_CANNOT_BE_ZERO);
    ownerships[_tokenId].price = price;
  }

  function notForSale(uint256 _tokenId) public onlyOwner(_tokenId) {
    ownerships[_tokenId].price = 0;
  }

  function getPrice(uint256 _tokenId) public view onlyForSale(_tokenId) returns (uint256) {
    return ownerships[_tokenId].price;
  }
}
