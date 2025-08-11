// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract OwnableTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyOwnerPrank() {
        vm.startPrank(simpleOwnable.owner());
        _;
    }

    function testOwner() public view {
        assertEq(simpleOwnable.owner(), owner);
    }

    function testTransferOwnership() public onlyOwnerPrank {
        simpleOwnable.transferOwnership(newOwner);
    }

    function testRenounceOwnership() public onlyOwnerPrank {
        simpleOwnable.renounceOwnership();
        vm.expectRevert();
        simpleOwnable.transferOwnership(newOwner);
    }
}
