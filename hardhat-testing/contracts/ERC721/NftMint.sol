// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

abstract contract MintNFT is ERC721, Ownable, ReentrancyGuard, PaymentSplitter {
    bytes32 immutable merkleRoot;
    bytes32[] proof;

    address[] private teamMembers = [
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];
    uint256[] private teamShares = [20, 40, 40];

    string private baseURI;

    // inializationn of contant is compulsory, const is gas efficient then immutable
    uint constant PRESALE_LIMIT = 5;
    uint constant NFT_PRICE = 0.01 ether;
    uint constant MAX_SUPPLLY = 20;

    bool public isPaused;
    bool public isPresaleActive;
    bool public isPublic;

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
    modifier isVerified() {
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
}
