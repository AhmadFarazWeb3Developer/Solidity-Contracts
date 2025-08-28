// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract CallTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_testCallFoo() public {
        caller.testCallFoo{value: 100 ether}(payable(address(receiver)));
    }
    function test_testCallDoesNotExist() public {
        caller.testCallDoesNotExist(payable(address(receiver)));
    }
}
