// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;
pragma solidity ^0.8.19;


import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleTree {
    bytes32 public root;

    constructor(bytes32 _root) {
        root = _root;
    }

    function safeMint(bytes32[] memory proof) public view returns (bool) {
        require(
            isValid(proof, keccak256(abi.encodePacked(msg.sender))),
            "Not a part of Allowlist"
        );
        return true;
    }

    function isValid(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal view returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}
