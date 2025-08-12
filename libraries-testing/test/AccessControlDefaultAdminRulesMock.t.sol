// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract AccessControlDefaultAdminRulesMock is UtilsTest {
    address minterAddress = makeAddr("minter");

    bytes32 minterRole;
    bytes32 adminRole;

    function setUp() public override {
        UtilsTest.setUp();

        minterRole = accessControlDefaultAdminRules.MINTER_ROLE();
        adminRole = accessControlDefaultAdminRules.DEFAULT_ADMIN_ROLE();
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

    function test_defaultAdmin() public view {
        accessControlDefaultAdminRules.defaultAdmin();
    }

    function test_defaultAdminDelay() public view {
        accessControlDefaultAdminRules.defaultAdminDelay();
    }

    function test_defaultAdminDelayIncreaseWait() public view {
        accessControlDefaultAdminRules.defaultAdminDelayIncreaseWait();
    }

    function test_acceptDefaultAdminTransfer() public onlyOwnerPrank {
        accessControlDefaultAdminRules.acceptDefaultAdminTransfer();
    }

    function test_pendingDefaultAdmin() public view {
        accessControlDefaultAdminRules.pendingDefaultAdmin();
    }
    function test_pendingDefaultAdminDelay() public view {
        accessControlDefaultAdminRules.pendingDefaultAdminDelay();
    }

    function test_beginDefaultAdminTransfer() public onlyOwnerPrank {
        accessControlDefaultAdminRules.beginDefaultAdminTransfer(newOwner);

        (
            address pendingAdmin,
            uint48 timeDelay
        ) = accessControlDefaultAdminRules.pendingDefaultAdmin();

        vm.warp(timeDelay + 1 days);

        vm.startPrank(pendingAdmin);
        accessControlDefaultAdminRules.acceptDefaultAdminTransfer();

        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert();
        accessControlDefaultAdminRules.grantRole(adminRole, owner);
    }

    function test_cancelDefaultAdminTransfer() public onlyOwnerPrank {
        accessControlDefaultAdminRules.beginDefaultAdminTransfer(newOwner);
        accessControlDefaultAdminRules.cancelDefaultAdminTransfer();
    }
    function test_rollbackDefaultAdminDelay() public onlyOwnerPrank {
      
        accessControlDefaultAdminRules.changeDefaultAdminDelay(3 days);

        vm.warp(accessControlDefaultAdminRules.defaultAdminDelay() + 3 days);

        accessControlDefaultAdminRules.rollbackDefaultAdminDelay();
    }
}

/*

DEFAULT_ADMIN_ROLE()               | a217fddf   |
|------------------------------------+------------|
| acceptDefaultAdminTransfer()       | cefc1429   |
|------------------------------------+------------|
| beginDefaultAdminTransfer(address) | 634e93da   |
|------------------------------------+------------|
| cancelDefaultAdminTransfer()       | d602b9fd   |
|------------------------------------+------------|
| changeDefaultAdminDelay(uint48)    | 649a5ec7   |
|------------------------------------+------------|
| defaultAdmin()                     | 84ef8ffc   |
|------------------------------------+------------|
| defaultAdminDelay()                | cc8463c8   |
|------------------------------------+------------|
| defaultAdminDelayIncreaseWait()    | 022d63fb   |
|------------------------------------+------------|
| getRoleAdmin(bytes32)              | 248a9ca3   |
|------------------------------------+------------|
| grantRole(bytes32,address)         | 2f2ff15d   |
|------------------------------------+------------|
| hasRole(bytes32,address)           | 91d14854   |
|------------------------------------+------------|
| owner()                            | 8da5cb5b   |
|------------------------------------+------------|
| pendingDefaultAdmin()              | cf6eefb7   |
|------------------------------------+------------|
| pendingDefaultAdminDelay()         | a1eda53c   |
|------------------------------------+------------|
| renounceRole(bytes32,address)      | 36568abe   |
|------------------------------------+------------|
| revokeRole(bytes32,address)        | d547741f   |
|------------------------------------+------------|
| rollbackDefaultAdminDelay()        | 0aa6220b   |
|------------------------------------+------------|
| supportsInterface(bytes4)          | 01ffc9a7   |
╰------------------------------------+------------╯

 */
