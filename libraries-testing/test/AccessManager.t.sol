// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract AccessManagerTest is UtilsTest {
    address guardian = makeAddr("guardian");

    bytes32 minterRole;

    function setUp() public override {
        UtilsTest.setUp();
        // minterRole = accessControl.MINTER_ROLE();
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

    function test_ADMIN_ROLE() public view {
        accessManager.ADMIN_ROLE();
    }

    function test_PUBLIC_ROLE() public view {
        accessManager.PUBLIC_ROLE();
    }

    function test_expiration() public view {
        accessManager.expiration();
    }

    function test_getRoleAdmin() public view {
        accessManager.getRoleAdmin(0);
    }

    function test_setRoleGuardian() public onlyOwnerPrank {
        accessManager.setRoleGuardian(1, 0);
        accessManager.getRoleGuardian(1);
    }

    function test_onlyAuthorized() public onlyOwnerPrank {
        accessManager.setRoleGuardian(1, 0); // generate role id for guradian

        accessManager.grantRole(0, guardian, 0); // assign role if

        vm.startPrank(guardian);

        accessManager.calledByAuthorized();

        vm.stopPrank();

        address unauthorized = makeAddr("unauthorized");
        vm.startPrank(unauthorized);
        vm.expectRevert();
        accessManager.calledByAuthorized();
        vm.stopPrank();
    }

    function test_getAccess() public onlyOwnerPrank {
        accessManager.setRoleGuardian(1, 0); // generate role id for guradian

        accessManager.grantRole(0, guardian, 0); // assign role if

        accessManager.getAccess(0, guardian);
    }

    function test_hasRole() public onlyOwnerPrank {
        accessManager.setRoleGuardian(1, 0); // generate role id for guradian

        accessManager.grantRole(0, guardian, 0); // assign role if

        accessManager.hasRole(0, guardian);
    }

    function test_labelRole() public onlyOwnerPrank {
        accessManager.labelRole(1, "Guard");
    }
}

/*
------------------------------------------------+------------╮
| Method                                         | Identifier |
+=============================================================+
| ADMIN_ROLE()                                   | 75b238fc   |
|------------------------------------------------+------------|
| PUBLIC_ROLE()                                  | 3ca7c02a   |
|------------------------------------------------+------------|
| canCall(address,address,bytes4)                | b7009613   |
|------------------------------------------------+------------|
| cancel(address,address,bytes)                  | d6bb62c6   |
|------------------------------------------------+------------|
| consumeScheduledOp(address,bytes)              | 94c7d7ee   |
|------------------------------------------------+------------|
| execute(address,bytes)                         | 1cff79cd   |
|------------------------------------------------+------------|
| expiration()                                   | 4665096d   |
|------------------------------------------------+------------|
| getAccess(uint64,address)                      | 3078f114   |
|------------------------------------------------+------------|
| getNonce(bytes32)                              | 4136a33c   |
|------------------------------------------------+------------|
| getRoleAdmin(uint64)                           | 530dd456   |
|------------------------------------------------+------------|
| getRoleGrantDelay(uint64)                      | 12be8727   |
|------------------------------------------------+------------|
| getRoleGuardian(uint64)                        | 0b0a93ba   |
|------------------------------------------------+------------|
| getSchedule(bytes32)                           | 3adc277a   |
|------------------------------------------------+------------|
| getTargetAdminDelay(address)                   | 4c1da1e2   |
|------------------------------------------------+------------|
| getTargetFunctionRole(address,bytes4)          | 6d5115bd   |
|------------------------------------------------+------------|
| grantRole(uint64,address,uint32)               | 25c471a0   |
|------------------------------------------------+------------|
| hasRole(uint64,address)                        | d1f856ee   |
|------------------------------------------------+------------|
| hashOperation(address,address,bytes)           | abd9bd2a   |
|------------------------------------------------+------------|
| isTargetClosed(address)                        | a166aa89   |
|------------------------------------------------+------------|
| labelRole(uint64,string)                       | 853551b8   |
|------------------------------------------------+------------|
| minSetback()                                   | cc1b6c81   |
|------------------------------------------------+------------|
| multicall(bytes[])                             | ac9650d8   |
|------------------------------------------------+------------|
| renounceRole(uint64,address)                   | fe0776f5   |
|------------------------------------------------+------------|
| revokeRole(uint64,address)                     | b7d2b162   |
|------------------------------------------------+------------|
| schedule(address,bytes,uint48)                 | f801a698   |
|------------------------------------------------+------------|
| setGrantDelay(uint64,uint32)                   | a64d95ce   |
|------------------------------------------------+------------|
| setRoleAdmin(uint64,uint64)                    | 30cae187   |
|------------------------------------------------+------------|
| setRoleGuardian(uint64,uint64)                 | 52962952   |
|------------------------------------------------+------------|
| setTargetAdminDelay(address,uint32)            | d22b5989   |
|------------------------------------------------+------------|
| setTargetClosed(address,bool)                  | 167bd395   |
|------------------------------------------------+------------|
| setTargetFunctionRole(address,bytes4[],uint64) | 08d6122d   |
|------------------------------------------------+------------|
| updateAuthority(address,address)               | 18ff183c   |
╰------------------------------------------------+------------╯
 */
