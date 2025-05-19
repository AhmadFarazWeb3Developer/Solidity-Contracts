// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MintNFT is ERC721, Ownable, ReentrancyGuard, PaymentSplitter {
    bytes32 immutable merkleRoot;

    address[] private teamMembers = [
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];
    uint256[] private teamShares = [20, 40, 40, 10];
    mapping(address => uint256) private presaleCount;
    mapping(uint256 => string) public tokenCIDs;
    string private baseURI;

    // inializationn of contant is compulsory, const is gas efficient then immutable
    uint256 constant PRESALE_LIMIT = 5;
    uint256 constant NFT_PRICE = 0.01 ether;
    uint256 constant MAX_SUPPLLY = 20;

    bool public isPaused;
    bool public isPresaleActive;
    bool public isPublicsaleActive;

    uint256 tokenCountId;

    constructor(
        bytes32 _root,
        string memory _baseURI
    )
        ERC721("Pak Blocks", "PKBK")
        Ownable()
        PaymentSplitter(teamMembers, teamShares)
    {
        merkleRoot = _root;
        baseURI = _baseURI;
    }

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "Contracts call not allowed");
        _;
    }
    modifier isVerified(bytes32[] memory proof) {
        require(
            MerkleProof.verify(
                proof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Proof is not valid"
        );
        _;
    }

    function togglePreSale() external onlyOwner {
        isPresaleActive = !isPresaleActive;
    }

    function togglePublicSale() external onlyOwner {
        isPublicsaleActive = !isPublicsaleActive;
    }

    function preSaleMint(
        uint256 _nftAmount,
        bytes32[] memory _proof,
        string[] calldata _cids
    ) external payable onlyEOA nonReentrant isVerified(_proof) {
        require(!isPublicsaleActive, "Contract not active");
        require(!isPresaleActive, "Contract not active");
        require(_nftAmount > 0, "nftAmount < 0");
        require(
            presaleCount[msg.sender] + _nftAmount <= PRESALE_LIMIT,
            "Presale limit exceeded"
        );
        require(
            tokenCountId + _nftAmount <= MAX_SUPPLLY,
            "MAX_SUPPLLY exceeded"
        );
        require(_cids.length == _nftAmount, "NFT Ammount != CIDs ");
        require(msg.value >= _nftAmount * NFT_PRICE, "Not enough eth");
        for (uint256 i = 0; i < _nftAmount; i++) {
            _mint(msg.sender, _cids[i]);
        }
    }

    function publicSaleMint(
        uint256 _nftAmount,
        string[] calldata _cids
    ) external payable onlyEOA nonReentrant {
        require(!isPublicsaleActive, "Contract not active");
        require(_nftAmount > 0, "nftAmount < 0");
        require(
            tokenCountId + _nftAmount <= MAX_SUPPLLY,
            "MAX_SUPPLLY exceeded"
        );
        require(_cids.length == _nftAmount, "NFT Ammount != CIDs ");
        require(msg.value >= _nftAmount * NFT_PRICE * 2, "Not enough eth"); // double the presale price
        for (uint256 i = 0; i < _nftAmount; i++) {
            _mint(msg.sender, _cids[i]);
        }
    }

    function _mint(address _to, string memory _cid) internal {
        _safeMint(_to, tokenCountId);
        tokenCIDs[tokenCountId] = _cid;

        tokenCountId++;
    }

    function totalSupply() public view returns (uint) {
        return tokenCountId;
    }

    function remainingSupply() public view returns (uint) {
        return MAX_SUPPLLY - tokenCountId;
    }

    function withDraw() external payable onlyOwner {
        require(address(this).balance > 0, "Insufficient balance");
        payable(msg.sender).transfer(address(this).balance);
    }
}
