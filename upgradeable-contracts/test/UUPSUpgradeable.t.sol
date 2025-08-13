// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract UUPSUpgradeableTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyAdmin() {
        vm.startPrank(admin);
        _;
    }

    function testProxy() public {
        uupsLogicMock.Initializer(10);
    }
}
