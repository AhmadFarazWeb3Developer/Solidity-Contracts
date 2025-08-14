// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";
import {UUPSLogicMock} from "./mocks/UUPSLogicMock.sol";

contract UUPSUpgradeableTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyAdmin() {
        vm.startPrank(admin);
        _;
    }

    function testProxy() public {
        UUPSLogicMock proxyCast = UUPSLogicMock(address(erc1967Proxy));
        proxyCast.value();
        proxyCast.name();
        proxyCast.version();
    }
}
