// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*


`abi.encodePacked` this function is specifically designed for tightly packing multiple values without adding any padding.



 */
contract DotEncodePacked {
    function AddressEncodePacked() external pure returns (bytes memory) {
        return (abi.encodePacked(0xD6b0794b7aeA7190F1831A40393e599CC0864EB3));
    }
    function BytesEncoded() external pure returns (bytes memory) {
        // return abi.encode(0xabcdef12); // this is not hex .
        /*
        uint256 can store:
        Decimal: 123456789
        Hexadecimal: 0xabcdef12
        Binary: 0b10101010
        Octal: 0o1234567
         */

        return abi.encodePacked(bytes4(0xabcdef12)); // fixed size bytes, no extra slot for offset and length required
    }

    function UintsEncodePacked() external pure returns (bytes memory) {
        return abi.encodePacked(uint(213451213231231231231231231231231235)); // ?
    }

    function BooleanEncodePacked() external pure returns (bytes memory) {
        return abi.encodePacked(true);
    }

    function StaticMixEncodePacked() external pure returns (bytes memory) {
        return
            abi.encodePacked(
                0xD6b0794b7aeA7190F1831A40393e599CC0864EB3,
                uint256(121312),
                bytes4(0xabcdef12)
            );
    }

    // -------------------- ENCODING OF DYNAMIC TYPES ------------------------------------------------

    function StringEncodePacked() external pure returns (bytes memory) {
        return abi.encodePacked("YUL");
        /*
    Memory is continous bytes:

    Byte 0-31:   0x0000...0020 (offset)
    Byte 32-63:  0x0000...0003 (length) 
    Byte 64-95:  0x59554c...00 (data)
    */
    }

    // when we write bytes, it become dynamic it will have require offset, length slots extra because we dont know the size
    // of data at runtime
    function DynamicBytesEncodePacked(
        bytes memory _data
    ) external pure returns (bytes memory) {
        return (abi.encodePacked(_data));
    }

    function UintsArrayEncodePacked() external pure returns (bytes memory) {
        uint256[] memory uintArrays = new uint256[](2);
        uintArrays[0] = 143;
        uintArrays[1] = 100;
        return abi.encodePacked(uintArrays);
    }

    function BytesArrayEncodePacked() external pure returns (bytes memory) {
        bytes4[] memory bytesArray = new bytes4[](2);
        bytesArray[0] = bytes4(0x123456e1);
        bytesArray[1] = bytes4(0xa12e3f8f);
        return abi.encodePacked(bytesArray);
    }

    // String Array CANNOT BE ENCODEPAKCED, its can be decoded back

    // function StringArrayEncodePacked() external pure returns (bytes memory) {
    //     string[] memory stringArray = new string[](2);
    //     stringArray[0] = "Hello are you enjoying the YUL Programming language";
    //     stringArray[1] = "Yes solidity made it awesome";

    //     return abi.encodePacked(stringArray);
    // }

    // struct myStruct {
    //     string data;
    //     uint256 id;
    // }

    // function StructEncodePacked() external pure returns (bytes memory) {
    //     myStruct memory s = myStruct({id: 1122, data: "Hello Yul!"});
    //     return abi.encodePacked(s);
    // }
}
