// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "../src/Ownable.sol";
import {Ownable2Step} from "../src/Ownable2Step.sol";

contract UtilsTest is Test {
    Ownable simpleOwnable;
    Ownable2Step twoStepOwnable;

    address owner = makeAddr("owner");
    address newOwner = makeAddr("newOwner");

    function setUp() public virtual {
        simpleOwnable = new Ownable(owner);
        twoStepOwnable = new Ownable2Step(owner);
    }
}
