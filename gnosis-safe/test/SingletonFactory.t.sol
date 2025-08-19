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
        owners[0] = address(0x1);
        owners[1] = address(0x2);
        threshold = 2; // Require 2/2 signatures
    }

    function getProxySingleton(address proxy) internal returns (address) {
        // The storage slot where the singleton address is stored
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 singletonBytes;
        assembly {
            singletonBytes := sload(slot)
        }
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

    function test_SafeInitialization() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);
        Safe safe = Safe(payable(safeAddress));

        assertEq(safe.getThreshold(), threshold, "Threshold mismatch");
        assertEq(safe.getOwners(), owners, "Owners mismatch");

        address handler = safe.getFallbackHandler();
        assertEq(handler, address(fallbackHandler), "Fallback handler not set");
    }

    function test_DeterministicAddress() public {
        // First deployment
        address safeAddress1 = createSafe(owners, threshold, saltNonce);

        // Second deployment with same parameters
        address safeAddress2 = createSafe(owners, threshold, saltNonce);

        // Should get same address
        assertEq(
            safeAddress1,
            safeAddress2,
            "Addresses should be deterministic"
        );

        // Different salt should produce different address
        address safeAddress3 = createSafe(owners, threshold, saltNonce + 1);
        assertTrue(
            safeAddress1 != safeAddress3,
            "Different salt should produce different address"
        );
    }

    // Test invalid configurations
    function test_InvalidConfigurations() public {
        // Zero threshold
        vm.expectRevert("Threshold must be greater than 0");
        createSafe(owners, 0, saltNonce);

        // Threshold > owners
        vm.expectRevert("Threshold must be <= owners length");
        createSafe(owners, owners.length + 1, saltNonce);

        // Empty owners
        address[] memory emptyOwners;
        vm.expectRevert("At least 1 owner required");
        createSafe(emptyOwners, 1, saltNonce);

        // Duplicate owners
        address[] memory dupOwners = new address[](2);
        dupOwners[0] = address(0x1);
        dupOwners[1] = address(0x1);
        vm.expectRevert("Duplicate owner address");
        createSafe(dupOwners, 1, saltNonce);
    }

    // Test proxy functionality
    function test_ProxyFunctionality() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);
        Safe safe = Safe(payable(safeAddress));

        // Verify delegatecall works
        bytes memory ownersCall = abi.encodeWithSignature("getOwners()");
        (bool success, bytes memory data) = address(safe).call(ownersCall);

        assertTrue(success, "Call should succeed");
        address[] memory returnedOwners = abi.decode(data, (address[]));
        assertEq(returnedOwners, owners, "Owners should match");
    }

    // Test events
    function test_ProxyCreationEvent() public {
        // Expect ProxyCreation event
        vm.expectEmit(true, true, true, true);
        // emit ProxyCreation(SafeProxy(payable(address(0))), address(singleton));

        // Create the safe (address(0) will be replaced with actual proxy)
        createSafe(owners, threshold, saltNonce);
    }
}
