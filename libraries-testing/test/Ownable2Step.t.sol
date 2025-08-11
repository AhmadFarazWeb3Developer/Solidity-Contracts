// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract Ownable2StepTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyOwnerPrank() {
        vm.startPrank(simpleOwnable.owner());
        _;
    }

    function test2Step_Owner() public view {
        assertEq(twoStepOwnable.owner(), owner);
    }

    function test2Step_TransferOwnership() public onlyOwnerPrank {
        twoStepOwnable.transferOwnership(newOwner);
        assertEq(twoStepOwnable.pendingOwner(), newOwner);
    }

    function test2Step_AcceptOwnership() public onlyOwnerPrank {
        twoStepOwnable.transferOwnership(newOwner);
        assertEq(twoStepOwnable.pendingOwner(), newOwner);

        vm.startPrank(newOwner);
        twoStepOwnable.acceptOwnership();
    }

    function test2Step_RenounceOwnership() public onlyOwnerPrank {
        twoStepOwnable.renounceOwnership();
        vm.expectRevert();
        twoStepOwnable.transferOwnership(newOwner);
    }
}
