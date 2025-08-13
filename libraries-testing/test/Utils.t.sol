// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "../src/Ownable/Ownable.sol";
import {Ownable2Step} from "../src/Ownable/Ownable2Step.sol";
import {AccessControl} from "../src/AccessControl/AccessControl.sol";
import {AccessControlMock} from "./mocks/AccessControlMock.sol";
import {AccessControlEnumerableMock} from "./mocks/AccessControlEnumerableMock.sol";

import {AccessControlDefaultAdminRulesMock} from "./mocks/AccessControlDefaultAdminRulesMock.sol";

import {AccessManagerMock} from "./mocks/AccessManagerMock.sol";
import {AccessManagedMock} from "./mocks/AccessManagedMock.sol";
import {AuthorityMock} from "./mocks/AuthorityMock.sol";

contract UtilsTest is Test {
    Ownable simpleOwnable;
    Ownable2Step twoStepOwnable;

    AccessControlMock accessControl;
    AccessControlEnumerableMock accessControlEnumerable;
    AccessControlDefaultAdminRulesMock accessControlDefaultAdminRules;

    AccessManagerMock accessManager;
    AccessManagedMock accessManaged;

    AuthorityMock newAuthority;

    address owner = makeAddr("owner");
    address newOwner = makeAddr("newOwner");

    function setUp() public virtual {
        simpleOwnable = new Ownable(owner);
        twoStepOwnable = new Ownable2Step(owner);
        accessControl = new AccessControlMock(owner);
        accessControlEnumerable = new AccessControlEnumerableMock(owner);

        accessControlDefaultAdminRules = new AccessControlDefaultAdminRulesMock(
            1 days,
            owner
        );

        accessManager = new AccessManagerMock(owner);

        accessManaged = new AccessManagedMock(owner);
        
        newAuthority = new AuthorityMock();
    }
}
