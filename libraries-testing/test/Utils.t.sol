// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "../src/Ownable.sol";

contract UtilsTest is Test {
    Ownable simpleOwnable;
    address owner = makeAddr("owner");
    function setUp() public virtual {
        simpleOwnable = new Ownable(owner);
    }
}
