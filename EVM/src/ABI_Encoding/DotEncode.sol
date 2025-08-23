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
        // return abi.encode(0xabcdef12); // this is not hex .
        /*
        uint256 can store:
        Decimal: 123456789
        Hexadecimal: 0xabcdef12
        Binary: 0b10101010
        Octal: 0o1234567
         */

        return abi.encode(bytes4(0xabcdef12)); // fixed size bytes, no extra slot for offset and length required
    }

    function UintsEncode() external pure returns (bytes memory) {
        return abi.encode(213451213231231231231231231231231235);
    }

    function BooleanEncode() external pure returns (bytes memory) {
        return abi.encode(true);
    }

    function StaticMix() external pure returns (bytes memory) {
        return
            abi.encode(
                0xD6b0794b7aeA7190F1831A40393e599CC0864EB3,
                121312,
                bytes4(0xabcdef12)
            );
    }

    // -------------------- ENCODING OF DYNAMIC TYPES ------------------------------------------------

    function StringEncode() external pure returns (bytes memory) {
        return abi.encode("YUL");
        /*
    Memory is continous bytes:

    Byte 0-31:   0x0000...0020 (offset)
    Byte 32-63:  0x0000...0003 (length) 
    Byte 64-95:  0x59554c...00 (data)
    */
    }

    // when we write bytes, it become dynamic it will have require offset, length slots extra because we dont know the size
    // of data at runtime
    function DynamicBytesEncode(
        bytes memory _data
    ) external pure returns (bytes memory) {
        return (abi.encode(_data));
    }

    function UintsArrayEncode() external pure returns (bytes memory) {
        uint256[] memory uintArrays = new uint256[](2);
        uintArrays[0] = 143;
        uintArrays[1] = 100;
        return abi.encode(uintArrays);
    }

    function BytesArrayEncode() external pure returns (bytes memory) {
        bytes4[] memory bytesArray = new bytes4[](2);
        bytesArray[0] = bytes4(0x123456e1);
        bytesArray[1] = bytes4(0xa12e3f8f);
        return abi.encode(bytesArray);
    }

    function StringArrayEncode() external pure returns (bytes memory) {
        string[] memory stringArray = new string[](2);
        stringArray[0] = "Hello are you enjoying the YUL Programming language";
        stringArray[1] = "Yes solidity made it awesome";

        return abi.encode(stringArray);
    }

    struct myStruct {
        string data;
        uint256 id;
    }

    function StructEncode() external pure returns (bytes memory) {
        myStruct memory s = myStruct({id: 1122, data: "Hello Yul!"});
        return abi.encode(s);
    }
}

/*
    The offset position doesn't change based on thse string's position in the function parameters!
    Key rule: In abi.encode, all static types come first, then all dynamic types, regardless of parameter order.
    */

// contract.call(data) ?
