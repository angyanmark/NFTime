// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ERC721.sol";
import "../interfaces/ERC721TokenReceiver.sol";
import "./utils/AddressUtils.sol";

contract NFT is ERC721 {
    using AddressUtils for address;

    string constant ZERO_ADDRESS = "Zero address";
    string constant NOT_VALID_NFT = "Not valid NFT";
    string constant NOT_OWNER_APPROVED_OR_OPERATOR =
        "Not owner, approved or operator";
    string constant NOT_OWNER = "Not owner";
    string constant NOT_ABLE_TO_RECEIVE_NFT = "Not able to receive NFT";
    string constant NFT_ALREADY_EXISTS = "NFT already exists";
    string constant NOT_OWNER_OR_OPERATOR = "Not owner or operator";
    string constant IS_OWNER = "Is owner";
    string constant NFT_NOT_FOR_SALE = "NFT not for sale";
    string constant NFT_COSTS_MORE = "NFT costs more";
    string constant PRICE_CANNOT_BE_ZERO = "Price cannot be zero";
    bytes4 private constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    struct ImageToken {
        address owner;
        string uri;
        uint256 price;
        address approvedPerson;
    }

    uint256 nextID = 1;
    
    mapping(uint256 => ImageToken) private idToImageToken;
    mapping(address => uint256) private ownerToNFTCount;
    mapping(address => mapping(address => bool)) private ownerToOperators;

    modifier onlyForSale(uint256 _tokenId) {
        require(idToImageToken[_tokenId].price != 0, NFT_NOT_FOR_SALE);
        _;
    }

    modifier onlyOwner(uint256 _tokenId) {
        require(idToImageToken[_tokenId].owner == msg.sender, NOT_OWNER);
        _;
    }

    modifier canApprove(uint256 _tokenId) {
        address tokenOwner = idToImageToken[_tokenId].owner;
        require(
            tokenOwner == msg.sender ||
                ownerToOperators[tokenOwner][msg.sender],
            NOT_OWNER_OR_OPERATOR
        );
        _;
    }

    modifier authorized(uint256 _tokenId) {
        address tokenOwner = idToImageToken[_tokenId].owner;
        require(
            tokenOwner == msg.sender ||
                idToImageToken[_tokenId].approvedPerson == msg.sender ||
                ownerToOperators[tokenOwner][msg.sender],
            NOT_OWNER_APPROVED_OR_OPERATOR
        );
        _;
    }

    modifier validNFT(uint256 _tokenId) {
        require(idToImageToken[_tokenId].owner != address(0), NOT_VALID_NFT);
        _;
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        require(_owner != address(0), ZERO_ADDRESS);
        return ownerToNFTCount[_owner];
    }

    function ownerOf(uint256 _tokenId)
        public
        view
        override
        validNFT(_tokenId)
        returns (address)
    {
        return idToImageToken[_tokenId].owner;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) public payable override {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) private authorized(_tokenId) validNFT(_tokenId) {
        address tokenOwner = idToImageToken[_tokenId].owner;
        require(tokenOwner == _from, NOT_OWNER);
        require(_to != address(0), ZERO_ADDRESS);
        _transfer(_to, _tokenId);

        if (_to.isContract()) {
            bytes4 retval =
                ERC721TokenReceiver(_to).onERC721Received(
                    msg.sender,
                    _from,
                    _tokenId,
                    _data
                );
            require(
                retval == MAGIC_ON_ERC721_RECEIVED,
                NOT_ABLE_TO_RECEIVE_NFT
            );
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable override authorized(_tokenId) validNFT(_tokenId) {
        address tokenOwner = idToImageToken[_tokenId].owner;
        require(tokenOwner == _from, NOT_OWNER);
        require(_to != address(0), ZERO_ADDRESS);
        _transfer(_to, _tokenId);
    }

    function _transfer(address _to, uint256 _tokenId) private {
        address from = idToImageToken[_tokenId].owner;

        _changeOwner(_tokenId, from, _to);

        emit Transfer(from, _to, _tokenId);
    }

    function _clearApproval(uint256 _tokenId) private {
        idToImageToken[_tokenId].approvedPerson = address(0);
        emit Approval(idToImageToken[_tokenId].owner, address(0), _tokenId);
    }

    function buy(uint256 _tokenId) public payable onlyForSale(_tokenId) {
        ImageToken memory imageToken = idToImageToken[_tokenId];

        require(imageToken.price != 0, NFT_NOT_FOR_SALE);
        require(msg.value >= imageToken.price, NFT_COSTS_MORE);
        require(imageToken.owner != msg.sender, IS_OWNER);

        payable(imageToken.owner).transfer(msg.value);
        _changeOwner(_tokenId, imageToken.owner, msg.sender);
    }

    function _changeOwner(uint256 _tokenId, address _from, address _to) private {
        require(idToImageToken[_tokenId].owner == _from, NOT_OWNER);

        ownerToNFTCount[_from]--;
        ownerToNFTCount[_to]++;

        idToImageToken[_tokenId].owner = _to;
        idToImageToken[_tokenId].price = 0;
        _clearApproval(_tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        public
        payable
        override
        canApprove(_tokenId)
        validNFT(_tokenId)
    {
        address tokenOwner = idToImageToken[_tokenId].owner;
        require(_approved != tokenOwner, IS_OWNER);
        idToImageToken[_tokenId].approvedPerson = _approved;
        
        emit Approval(tokenOwner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        public
        override
    {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        public
        view
        override
        validNFT(_tokenId)
        returns (address)
    {
        return idToImageToken[_tokenId].approvedPerson;
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        return ownerToOperators[_owner][_operator];
    }

    function mint(string memory _uri) public returns (uint256) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        require(idToImageToken[nextID].owner == address(0), NFT_ALREADY_EXISTS);

        idToImageToken[nextID] = ImageToken(msg.sender, _uri, 0, address(0));

        ownerToNFTCount[msg.sender]++;

        emit Transfer(address(0), msg.sender, nextID);
        return nextID++;
    }

    function burn(uint256 _tokenId) public authorized(_tokenId) {
        address tokenOwner = idToImageToken[_tokenId].owner;

        delete idToImageToken[_tokenId];

        ownerToNFTCount[tokenOwner]--;

        emit Transfer(tokenOwner, address(0), _tokenId);
    }

    function forSale(uint256 _tokenId, uint256 price)
        public
        authorized(_tokenId)
    {
        require(price != 0, PRICE_CANNOT_BE_ZERO);
        idToImageToken[_tokenId].price = price;
    }

    function notForSale(uint256 _tokenId)
        public
        authorized(_tokenId)
        onlyForSale(_tokenId)
    {
        idToImageToken[_tokenId].price = 0;
    }

    function getPrice(uint256 _tokenId)
        public
        view
        validNFT(_tokenId)
        onlyForSale(_tokenId)
        returns (uint256)
    {
        return idToImageToken[_tokenId].price;
    }
}
