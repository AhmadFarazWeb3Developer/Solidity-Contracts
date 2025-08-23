// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*
ABI encoding involves converting static types, user-defined types, dynamic types like strings, 
and arrays into bytes through serialization. This is integral in the Ethereum ecosystem to ensure the seamless interaction between contracts. 
The serialization adheres to the Ethereum ABI specifications, a critical standard that ensures that data, 
regardless of its type, is consistently formatted and transmitted efficiently.
*/

contract DotEncode {
    /* abi.encode(arg); takes any arbitrary amount of arguments of various types and return bytes memory.
    abi.encode is designed to handle most of the static types in Solidity such as address, uint256, or bytes32, 
    each being encoded as 32-byte words. The padding of bytes is determined by the underlying Solidity types 
    which are being encoded.

    For Instance:
// ENCODING OF STATIC TYPES :
    address and other static types less than 32 bytes such as uint8 are zero-padded on the left side. 
    */
    function AddressEncode() external pure returns (bytes memory) {
        return (abi.encode(0xD6b0794b7aeA7190F1831A40393e599CC0864EB3));
    }

    //   Fixed-size byte values (like bytes4, bytes8, bytes12, etc.) are zero-padded on the right side.
    function BytesEncode() external pure returns (bytes memory) {
        return abi.encode(0xabcdef12);
    }

    function UintsEncode() external pure returns (bytes memory) {
        return abi.encode(213451213231231231231231231231231235);
    }

    function StaticMix() external pure returns (bytes memory) {
        return
            abi.encode(
                0xD6b0794b7aeA7190F1831A40393e599CC0864EB3,
                121312,
                0xabcdef12
            );
    }
    // ENCODING OF DYNAMIC TYPES

    function StringEncode() external pure returns (bytes memory) {
        return abi.encode("YUL");
    }
}

/*
    The offset position doesn't change based on the string's position in the function parameters!
    Key rule: In abi.encode, all static types come first, then all dynamic types, regardless of parameter order.
     */

// contract.call(data) ?
