// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Interface that defines the standard function a contract must implement to receive ERC721 tokens safely
import "./IERC721Receiver.sol";

// Basic ERC721 implementation
contract ERC721 {
    // Token collection name (e.g., "CryptoKitties")
    string public name;

    // Token collection symbol (e.g., "CK")
    string public symbol;

    // Counter to keep track of the next token ID to be minted
    uint256 public nextTokenIdToMint;

    // Owner of the smart contract
    address public contractOwner;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping from owner address to number of owned tokens
    mapping(address => uint256) internal _balances;

    // Mapping from token ID to approved address (for single-token transfer)
    mapping(uint256 => address) internal _tokenApprovals;

    // Mapping from owner to operator approvals (for all-token transfers)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    // Mapping from token ID to metadata URI
    mapping(uint256 => string) _tokenUris;

    // Standard events for ERC721
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

    // Constructor sets token name and symbol, assigns contract owner
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        nextTokenIdToMint = 0;
        contractOwner = msg.sender;
    }

    // Returns how many tokens the address owns
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "!Add0"); // zero address not allowed
        return _balances[_owner];
    }

    // Returns the owner of a specific token ID
    function ownerOf(uint256 _tokenId) public view returns (address) {
        return _owners[_tokenId];
    }

    // Safe transfer from one address to another (basic version)
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        safeTransferFrom(_from, _to, _tokenId, ""); // call overloaded version with empty data
    }

    // Safe transfer with data, ensures recipient contract supports ERC721
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public payable {
        require(
            ownerOf(_tokenId) == msg.sender ||
                _tokenApprovals[_tokenId] == msg.sender ||
                _operatorApprovals[ownerOf(_tokenId)][msg.sender],
            "!Auth" // must be owner or approved
        );
        _transfer(_from, _to, _tokenId);
        require(
            _checkOnERC721Received(_from, _to, _tokenId, _data),
            "!ERC721Implementer"
        ); // ensure receiver is compliant
    }

    // Unsafe transfer without receiver check (use with caution)
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        require(
            ownerOf(_tokenId) == msg.sender ||
                _tokenApprovals[_tokenId] == msg.sender ||
                _operatorApprovals[ownerOf(_tokenId)][msg.sender],
            "!Auth"
        );
        _transfer(_from, _to, _tokenId);
    }

    // Approve another address to transfer a specific token
    function approve(address _approved, uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) == msg.sender, "!Owner");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }

    // Approve or remove approval for an operator to manage all sender's tokens
    function setApprovalForAll(address _operator, bool _approved) public {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Returns the approved address for a specific token ID
    function getApproved(uint256 _tokenId) public view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    // Returns true if an operator is approved to manage all of the owner's assets
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    // Mint a new token to a specified address with URI metadata
    function mintTo(address _to, string memory _uri) public {
        require(contractOwner == msg.sender, "!Auth"); // Only contract owner can mint
        _owners[nextTokenIdToMint] = _to;
        _balances[_to] += 1;
        _tokenUris[nextTokenIdToMint] = _uri;
        emit Transfer(address(0), _to, nextTokenIdToMint); // minting is a transfer from 0x0
        nextTokenIdToMint += 1;
    }

    // Returns the token URI (metadata) for a given token ID
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenUris[_tokenId];
    }

    // Returns the total number of tokens minted
    function totalSupply() public view returns (uint256) {
        return nextTokenIdToMint;
    }

    // Internal function to call onERC721Received on the recipient if it's a contract
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            // check if address is a contract
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason)) // bubble up revert reason
                    }
                }
            }
        } else {
            return true; // if not a contract, safe
        }
    }

    // Internal function to perform the transfer and update balances
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from, "!Owner");
        require(_to != address(0), "!ToAdd0"); // cannot transfer to zero address

        delete _tokenApprovals[_tokenId]; // clear approval
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId); // emit standard transfer event
    }
}
