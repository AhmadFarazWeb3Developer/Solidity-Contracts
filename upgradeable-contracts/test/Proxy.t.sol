// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {Test, console2} from "forge-std/Test.sol";

import {UtilsTest} from "./Utils.t.sol";

contract ProxyTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    function test_setVars_Imp1() public payable {
        proxy.setVars(address(implementation1), 30);

        assertEq(implementation1.num(), 30);

        assertEq(proxy.num(), 30);
    }

    function test_setVars_Imp2() public payable {
        proxy.setVars(address(implementation2), 100);

        // now getting newFeature , we cannot get it direclty beacasue dealing with old proxy // can be access only via slot

        uint256 newFeatureSlotValue = uint256(
            vm.load(address(proxy), bytes32(uint256(3)))
        );
        assertEq(newFeatureSlotValue, 10000);
        assertEq(proxy.num(), 100 * newFeatureSlotValue);
    }
}
