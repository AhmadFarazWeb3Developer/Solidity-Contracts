// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract StringsTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_31BytesString() public {
        strings.the31BytesString();

        string memory str = strings.myString();
        console.log(bytes(str).length);
    }
}
