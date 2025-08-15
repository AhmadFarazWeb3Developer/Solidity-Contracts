// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";
import {UUPS_V1} from "./mocks/UUPSMocks/UUPS_V1.sol";
import {UUPS_V2} from "./mocks/UUPSMocks/UUPS_V2.sol";

contract UUPSUpgradeableTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyAdmin() {
        vm.startPrank(admin);
        _;
    }

    function testProxy() public onlyAdmin {
        UUPS_V1 proxyCastV1 = UUPS_V1(address(erc1967Proxy));

        bytes32 implSlot = bytes32(
            uint256(keccak256("eip1967.proxy.implementation")) - 1
        );
        bytes32 implAddrBytes = vm.load(address(erc1967Proxy), implSlot);

        address implAddr = address(uint160(uint256(implAddrBytes)));
        console2.log("Implementation address:", implAddr);

        proxyCastV1.upgradeToAndCall(
            address(uupsV2),
            abi.encodeWithSelector(uupsV2.initialize.selector, admin)
        );

        console2.log("Implementation address:", implAddr);
    }
}
