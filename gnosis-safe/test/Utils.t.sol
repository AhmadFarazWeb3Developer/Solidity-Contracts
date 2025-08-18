// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Safe} from "../src/Safe.sol";

abstract contract UtilsTest is Test {
    Safe safe;
    function setUp() public virtual {
        safe = new Safe();
    }
}
