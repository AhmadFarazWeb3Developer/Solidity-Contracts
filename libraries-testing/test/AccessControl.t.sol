// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract AccessControlTest is UtilsTest {
    address minterAddress = makeAddr("minter");

    bytes32 minterRole;

    function setUp() public override {
        UtilsTest.setUp();

        minterRole = accessControl.MINTER_ROLE();
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

    function test_hasRole() public view {
        accessControl.hasRole(accessControl.DEFAULT_ADMIN_ROLE(), owner);
    }

    function test_grantRole() public onlyOwnerPrank {
        accessControl.grantRole(minterRole, minterAddress);

        assertEq(accessControl.hasRole(minterRole, minterAddress), true);
    }

    function test_revokeRole() public onlyOwnerPrank {
        accessControl.grantRole(minterRole, minterAddress);
        accessControl.revokeRole(minterRole, minterAddress);
    }

    function test_renounceRole() public onlyOwnerPrank {
        accessControl.grantRole(minterRole, minterAddress);

        vm.startPrank(minterAddress);
        accessControl.renounceRole(minterRole, minterAddress);
    }

    function test_calledByMinter() public onlyOwnerPrank {
        accessControl.grantRole(minterRole, minterAddress);

        vm.startPrank(minterAddress);
        accessControl.calledByMinter();
    }
}
