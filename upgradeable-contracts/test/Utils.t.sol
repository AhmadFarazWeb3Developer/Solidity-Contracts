// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Implementation1} from "../src/basic/Implementation1.sol";
import {Implementation2} from "../src/basic/Implementation2.sol";

import {Proxy} from "../src/basic/Proxy.sol";

contract UtilsTest is Test {
    Proxy proxy;
    Implementation1 implementation1;

    Implementation2 implementation2;

    function setUp() public virtual {
        implementation1 = new Implementation1();
        implementation2 = new Implementation2();

        proxy = new Proxy();
    }
}
