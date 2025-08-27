// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract DotEncodeWithSignatureTest is UtilsTest {
    address dummyAddress = makeAddr("dummy addr");
    address target = makeAddr("target");

    function setUp() public override {
        super.setUp();
    }

    function test_foo() public view {
        dotEncodeWithSignature.EnodeSignature(); // 0x2fbebd380000000000000000000000000000000000000000000000000000000000000005
    }

    function test_execute() public {
        bytes memory actionData = abi.encodeWithSignature(
            "foo(address,address)",
            dummyAddress,
            target
        );
        dotEncodeWithSignature.execute(target, actionData);
    }

    function test_EncodeDynamicSignature() public view {
        uint256[] memory array = new uint256[](3);
        array[0] = 1;
        array[1] = 2;
        array[2] = 3;

        // can encode any thing
        bytes memory data = abi.encodeWithSignature(
            "EncodeDynamicSignature(uint256[],address)",
            array,
            dummyAddress
        );
        console.log(dummyAddress);
        dotEncodeWithSignature.EncodeDynamicSignature(target, data);

        /*
          0x2d1d989af240B673C84cEeb3E6279Ea98a2CFd05 , 

           0x827af310 -> function selector
           0000000000000000000000000000000000000000000000000000000000000040 -> array offset 
           000000000000000000000000dd9b878eea0df936e45b2c772ed70e550aecacb6  -> dummy address
           0000000000000000000000000000000000000000000000000000000000000003 -> length of array
           0000000000000000000000000000000000000000000000000000000000000001 -> first  element
           0000000000000000000000000000000000000000000000000000000000000002 -> second element
           0000000000000000000000000000000000000000000000000000000000000003 -> third element
        
         */
    }
}
