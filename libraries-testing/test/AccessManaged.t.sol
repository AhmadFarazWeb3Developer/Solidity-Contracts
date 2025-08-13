// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {UtilsTest} from "./Utils.t.sol";

contract AccessManagerTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyOwnerPrank() {
        vm.startPrank(owner);
        _;
    }
    modifier onlyUnauthorizedPrank() {
        address unauthorized = makeAddr("unauthorized");
        vm.startPrank(unauthorized);
        _;
    }

    function test_Authority() public view {
        accessManaged.authority();
    }
    function test_setAuthority() public onlyOwnerPrank {
        accessManaged.setAuthority(address(newAuthority));
    }
    function test_isConsumingScheduledOp() public view {
        accessManaged.isConsumingScheduledOp();
    }

    function test_calledByAuthorized() public onlyOwnerPrank {
        accessManaged.setAuthority(address(newAuthority));
        vm.startPrank(address(newAuthority));
        accessManaged.calledByAuthorized();
    }
}

/*

╭--------------------------+------------╮
| Method                   | Identifier |
+=======================================+
| authority()              | bf7e214f   |
|--------------------------+------------|
| isConsumingScheduledOp() | 8fb36037   |
|--------------------------+------------|
| setAuthority(address)    | 7a9e5e4b   |
╰--------------------------+------------╯

 */
