// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EIP712Auth {
    using ECDSA for bytes32;

    bool public s_action;

    // struct EIP712Domain {
    //     string name;
    //     string version;
    //     uint256 chainId;
    //     address verifyingContract;
    // }

    // EIP712Domain eip_712_domain_separator_struct =
    //     EIP712Domain({
    //         name: "EIP712Auth",
    //         version: "1",
    //         chainId: 1,
    //         verifyingContract: address(this)
    //     });

    bytes32 private immutable DOMAIN_SEPARATOR;
    bytes32 private constant DOMAINTYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 private constant AUTHTYPE_HASH =
        keccak256("Authorize(address authorizedUser,uint256 deadline)");

    address private immutable s_owner =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                // domain type hashing
                DOMAINTYPE_HASH,
                // domain values setting
                keccak256(bytes("EIP712Auth")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function executeWithAuth(
        uint256 deadline,
        bytes calldata signature
    ) external {
        require(block.timestamp <= deadline, "Signature expired");

        // Recover who this signature authorizes
        bytes32 structHash = keccak256(
            abi.encode(AUTHTYPE_HASH, msg.sender, deadline)
        );

        /* \x19\x01
        This is the EIP-191 header that marks the message as an EIP-712 typed message. 
        \x19: This is the fixed prefix defined in EIP-191 to distinguish signed messages from transactions.
        \x01: This is the version byte, which signals that the message is using EIP-712 structured data format (version 0x01 of EIP-191).
        */

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        address signingOwner = digest.recover(signature);

        require(signingOwner == s_owner, "Invalid signature");

        s_action = true;
    }
}
