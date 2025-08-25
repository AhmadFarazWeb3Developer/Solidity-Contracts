// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract DotEncodedPackedTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_AddressEncoded() public view {
        dotEncodePacked.AddressEncodePacked(); // 0xd6b0794b7aea7190f1831a40393e599cc0864eb3
    }
    function test_BytesEncoded() public view {
        dotEncodePacked.BytesArrayEncodePacked(); // 0xabcdef12
    }
    function test_UintsEncoded() public view {
        dotEncodePacked.UintsEncodePacked();
    }

    function test_BooleanEncoded() public view {
        dotEncodePacked.BooleanEncodePacked(); // 0x01
    }
    function test_StaticMixEncoded() public view {
        dotEncodePacked.StaticMixEncodePacked();

        // adddress
        // number
        // bytes4

        // 0xd6b0794b7aea7190f1831a40393e599cc0864eb3
        // 000000000000000000000000000000000000000000000000000000000001d9e0
        // abcdef12
    }

    function test_StringEncoded() public view {
        dotEncodePacked.StringEncodePacked();
    }

    function test_DynamicBytesEncoded() public view {
        dotEncodePacked.DynamicBytesEncodePacked(hex"01212fdaffcde5"); // 0x01212fdaffcde5
    }

    function test_UintsArrayEncodePacked() public view {
        dotEncodePacked.UintsArrayEncodePacked(); // 0x000000000000000000000000000000000000000000000000000000000000008f
        //  0000000000000000000000000000000000000000000000000000000000000064
    }
    function test_BytesArrayEncodePacked() public view {
        dotEncodePacked.BytesArrayEncodePacked(); // 0x123456e100000000000000000000000000000000000000000000000000000000a12e3f8f00000000000000000000000000000000000000000000000000000000

        /*
       for fixed-size types inside an array, Solidity still expands them to their natural ABI slot size = 32 bytes each, even when using encodePacked.
     */
    }

    
}
