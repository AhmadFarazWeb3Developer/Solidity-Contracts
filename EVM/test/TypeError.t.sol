// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract TypeErrorTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_TypeErrorNotImplicitlyConvertible() public {
        typeError.TypeErrorNotImplicitlyConvertible(100);
    }

    function test_sstoreHasNoTypeCheck() public {
        typeError.owner(); // 0xC257274276a4E539741Ca11b590B9447B26A8051

        // updated with uint value
        typeError.sstoreHasNoTypeCheck(100);

        // owner is vanished now, it is 100 = 64 in hex
        typeError.owner(); //   0x0000000000000000000000000000000000000064
    }
}
