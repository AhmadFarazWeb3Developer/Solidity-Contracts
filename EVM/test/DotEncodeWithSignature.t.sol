// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract DotEncodeWithSignatureTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_foo() public view {
        dotEncodeWithSignature.EnodeSignature(); // 0x2fbebd380000000000000000000000000000000000000000000000000000000000000005
    }
}
