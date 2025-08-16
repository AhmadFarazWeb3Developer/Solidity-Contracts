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
        UUPS_V1 proxyCast = UUPS_V1(address(erc1967Proxy));

        address implAddr = _getImplementation();
        assertEq(implAddr, address(uupsV1));

        proxyCast.upgradeToAndCall(
            address(uupsV2),
            abi.encodeWithSelector(uupsV2.initialize.selector, admin)
        );
        implAddr = _getImplementation();

        assertEq(implAddr, address(uupsV2));

        // UUPS_V1 proxyCast = UUPS_V1(address(erc1967Proxy));
        proxyCast.setValue(1000);
    }

    function _getImplementation() internal view returns (address) {
        // ERC1967 implementation slot
        bytes32 slot = bytes32(
            uint256(keccak256("eip1967.proxy.implementation")) - 1
        );

        bytes32 implBytes = vm.load(address(erc1967Proxy), slot);
        return address(uint160(uint256(implBytes)));
    }
}
