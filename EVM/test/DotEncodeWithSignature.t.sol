// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
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
}
