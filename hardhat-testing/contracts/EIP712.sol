// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EIP712 {
    using ECDSA for bytes32;

    bool public value;

    string private constant NAME = "EIP712Demo";
    string private constant VERSION = "1";
    bytes32 private immutable DOMAIN_SEPARATOR;

    // The authorized signer (set this to a real address!)
    address public immutable authorizedSigner;

    // keccak256("SetValue(address caller,uint256 deadline)")
    bytes32 private constant SETVALUE_TYPEHASH =
        keccak256("SetValue(address caller,uint256 deadline)");

    constructor(address _authorizedSigner) {
        authorizedSigner = _authorizedSigner;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(this)
            )
        );
    }

    function setValue(uint256 deadline, bytes calldata _signature) external {
        require(block.timestamp <= deadline, "Signature expired");

        bytes32 structHash = keccak256(
            abi.encode(SETVALUE_TYPEHASH, msg.sender, deadline)
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        address recoveredSigner = digest.recover(_signature);

        require(recoveredSigner == authorizedSigner, "Not authorized");

        value = true;
    }
}
