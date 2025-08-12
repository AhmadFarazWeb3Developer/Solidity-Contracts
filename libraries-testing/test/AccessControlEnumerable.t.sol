// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract AccessControlEnumerableTest is UtilsTest {
    address minterAddress = makeAddr("minter");

    bytes32 minterRole;
    bytes32 adminRole;

    function setUp() public override {
        UtilsTest.setUp();

        minterRole = accessControlEnumerable.MINTER_ROLE();
        adminRole = accessControlEnumerable.DEFAULT_ADMIN_ROLE();
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

    function test_getAdminRole() public view {
        accessControlEnumerable.getRoleMember(adminRole, 0);
    }

    function test_getRoleMembers() public onlyOwnerPrank {
        accessControlEnumerable.grantRole(minterRole, minterAddress);
        accessControlEnumerable.getRoleMembers(minterRole);
    }
}
