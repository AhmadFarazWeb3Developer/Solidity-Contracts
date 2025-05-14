// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ERC721 {
    // Merkle tree :
    // Merkle Proof :

    string collectionName;
    string collectionSymbol;
    uint totalTokensSupply;

    mapping(uint => string) public tokenURIs;
    mapping(address => uint) public balances;
    mapping(uint => address) public tokenOwner;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(uint => address) approvedAddress;

    // calldata cannot be used in constructor for string : why ?
    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        collectionName = _name;
        collectionSymbol = _symbol;
        totalTokensSupply = _totalSupply;
    }

    // A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory _name) {
        return collectionName;
    }

    /// An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory _symbol) {
        return collectionSymbol;
    }

    function totalSupply() external view returns (uint256) {
        return totalTokensSupply;
    }

    // token identifier
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return tokenURIs[_tokenId];
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenOwner[_tokenId];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        require(allowance[_from][_to] == _tokenId, "You dont have approval");
        uint tokenId = balances[_from];
        balances[_from] = 0;
        balances[_to] = tokenId;
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        allowance[msg.sender][_approved] = _tokenId;
        approvedAddress[_tokenId] = _approved;
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return approvedAddress[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {}

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool) {}

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
}
