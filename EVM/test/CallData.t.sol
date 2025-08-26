// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract CallDataTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_ProcessArray() public view {
        uint256[] memory array = new uint256[](3);
        array[0] = 100;
        array[1] = 200;
        array[2] = 300;
        callData.processArray(array);
    }

    function test_EchoMessage() public view {
        callData.echoMessage("YUL");
    }
}
