// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract DotEncodeWithSelectorTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_EncodeWithSelector() public view {
        dotEncodeWithSelector.EncodeWithSelector();

        /*
        0xa9059cbb -> function selector 
          000000000000000000000000f62849f9a0b5bf2913b396098f7c7019b51a820a -> address
          00000000000000000000000000000000000000000000003635c9adc5dea00000 -> balance
         */
    }
}
