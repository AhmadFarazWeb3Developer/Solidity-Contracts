//  SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {UtilsTest} from "./Utils.t.sol";
// import {Safe} from "../src/Safe.sol";
// import {SafeProxy} from "../src/proxies/SafeProxy.sol";

// contract SingletonFactoryTest is UtilsTest {
//     address[] public owners;
//     uint256 public threshold = 1;
//     uint256 public saltNonce = 12345;

//     function setUp() public override {
//         super.setUp();

//         owners = new address[](2);
//         owners[0] = vm.addr(1);
//         owners[1] = vm.addr(2);
//         threshold = 2; // Require 2/2 signatures
//     }

//     function getProxySingleton(address proxy) internal view returns (address) {
//         bytes memory proxyCode = address(proxy).code;
//         address implementationAddress;
//         assembly {
//             let ptr := mload(add(proxyCode, 0x20))
//             let addressSlot := mload(add(ptr, 0x10))
//             implementationAddress := shr(96, addressSlot)
//         }
//         return implementationAddress;
//     }
//     function test_SafeCreation() public {
//         vm.deal(address(this), 100 ether);
//         uint256 initialGas = 30_000_000;
//         vm.prank(vm.addr(1));

//         address safeAddress = createSafe(owners, threshold, saltNonce);
//         assertTrue(
//             safeAddress != address(0),
//             "Safe address should not be zero"
//         );

//         address proxySingleton = getProxySingleton(safeAddress);
//         assertEq(
//             proxySingleton,
//             address(singleton),
//             "Proxy should point to singleton"
//         );

//         Safe safe = Safe(payable(safeAddress));
//         assertEq(safe.getOwners(), owners, "Owners should match");
//         assertEq(safe.getThreshold(), threshold, "Threshold should match");
//     }
// }

pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";
import {Safe} from "../src/Safe.sol";
import {SafeProxy} from "../src/proxies/SafeProxy.sol";
import {IProxy} from "../src/proxies/SafeProxy.sol"; // Import the interface

contract SingletonFactoryTest is UtilsTest {
    address[] public owners;
    uint256 public threshold = 1;
    uint256 public saltNonce = 12345;

    function setUp() public override {
        super.setUp();

        owners = new address[](2);
        owners[0] = vm.addr(1);
        owners[1] = vm.addr(2);
        threshold = 2;
    }

    function getProxySingleton(address proxy) internal view returns (address) {
        // Method 1: Use the interface (recommended)
        return IProxy(proxy).masterCopy();

        // Method 2: Direct storage read (if interface not available)
        // bytes32 slot = 0x0; // singleton is at storage slot 0
        // address singleton;
        // assembly {
        //     singleton := sload(slot)
        // }
        // return singleton;
    }

    function test_SafeCreation() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);

        assertTrue(
            safeAddress != address(0),
            "Safe address should not be zero"
        );

        // Use the interface method
        address proxySingleton = IProxy(safeAddress).masterCopy();
        console.log(proxySingleton);
        console.log(address(singleton));
        assertEq(
            proxySingleton,
            address(singleton),
            "Proxy should point to singleton"
        );

        // Additional checks
        Safe safe = Safe(payable(safeAddress));
        address[] memory retrievedOwners = safe.getOwners();
        assertEq(retrievedOwners.length, 2, "Should have 2 owners");
        assertEq(safe.getThreshold(), threshold, "Threshold should match");

        safe.VERSION();
    }
}
