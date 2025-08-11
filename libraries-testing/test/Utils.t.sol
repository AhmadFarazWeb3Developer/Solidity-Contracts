// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "../src/Ownable/Ownable.sol";
import {Ownable2Step} from "../src/Ownable/Ownable2Step.sol";
import {AccessControl} from "../src/AccessControl/AccessControl.sol";
import {AccessControlMock} from "./mocks/AccessControlMock.sol";

contract UtilsTest is Test {
    Ownable simpleOwnable;
    Ownable2Step twoStepOwnable;

    AccessControlMock accessControl;

    address owner = makeAddr("owner");
    address newOwner = makeAddr("newOwner");

    function setUp() public virtual {
        simpleOwnable = new Ownable(owner);
        twoStepOwnable = new Ownable2Step(owner);
        accessControl = new AccessControlMock(owner);
    }
}
