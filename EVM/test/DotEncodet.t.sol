// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {Test, console, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract DotEncodeTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    // Static Types Encoding
    function test_AddressEncode() public view {
        dotEncode.AddressEncode(); // 0x000000000000000000000000d6b0794b7aea7190f1831a40393e599cc0864eb3
    }
    function test_BytesEncode() public view {
        dotEncode.BytesEncode(); // 0x00000000000000000000000000000000000000000000000000000000abcdef12
    }
    function test_UintsEncode() public view {
        dotEncode.UintsEncode(); //  0x0000000000000000000000000000000000291bf5139ecbf97aeba956631f8503
    }

    function test_StaticMix() public view {
        dotEncode.StaticMix(); // 0x000000000000000000000000d6b0794b7aea7190f1831a40393e599cc0864eb3000000000000000000000000000000000000000000000000000000000001d9e000000000000000000000000000000000000000000000000000000000abcdef12
    }

    // Dynamic Types Encoding

    function test_StringEncode() public view {
        dotEncode.StringEncode();
        /*
        0x0000000000000000000000000000000000000000000000000000000000000020 -> offset
          0000000000000000000000000000000000000000000000000000000000000003 -> length
          59554c0000000000000000000000000000000000000000000000000000000000 -> content
         */
    }
}

/*

Some Solidity types are not supported by the ABI, but they are able to be represented by the static types below.
  ┌───────────────────────────┬───────────────────────────┐
  │        Solidity Type      │          ABI Type         │
  ├───────────────────────────┼───────────────────────────┤
  │ address payable           │ address                   │
  │ contract                  │ address                   │
  │ enum                      │ uint8                     │
  │ user defined value types  │ underlying value type     │
  │ struct                    │ tuple                     │
  └───────────────────────────┴───────────────────────────┘


  It means if we try to abi.encode(payable(anyAddress)), so payable does not effect the encoded bytes 

*/
