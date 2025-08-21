// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract ConstantIsNotOnStorageTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_readConstant() public view {
        constantVar.readConstant();
    }
}
