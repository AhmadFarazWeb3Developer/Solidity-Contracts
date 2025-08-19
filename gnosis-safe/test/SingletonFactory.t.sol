// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";
import {Safe} from "../src/Safe.sol";
import {SafeProxy} from "../src/proxies/SafeProxy.sol";

contract SingletonFactoryTest is UtilsTest {
    address[] public owners;
    uint256 public threshold = 1;
    uint256 public saltNonce = 12345;

    function setUp() public override {
        super.setUp();

        owners = new address[](2);
        owners[0] = vm.addr(1);
        owners[1] = vm.addr(2);
        threshold = 2; // Require 2/2 signatures
    }

    function getProxySingleton(address proxy) internal view returns (address) {
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 singletonBytes = vm.load(proxy, slot);
        return address(uint160(uint256(singletonBytes)));
    }

    function test_SafeCreation() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);

        // Verify the proxy was created
        assertTrue(
            safeAddress != address(0),
            "Safe address should not be zero"
        );

        address proxySingleton = getProxySingleton(safeAddress);

        assertEq(
            proxySingleton,
            address(singleton),
            "Proxy should point to singleton"
        );
    }

    /
}
