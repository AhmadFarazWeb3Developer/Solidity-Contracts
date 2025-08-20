//  SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Safe} from "../src/Safe.sol";
import {SafeProxy} from "../src/proxies/SafeProxy.sol";
import {IProxy} from "../src/proxies/SafeProxy.sol";
import {UtilsTest} from "./Utils.t.sol";
import {Test, console} from "forge-std/Test.sol";

import {Enum} from "../src/libraries/Enum.sol";
import {SimpleGuard} from "./guard/SimpleGuard.sol";

contract SafeWalletCreationTest is UtilsTest {
    address[] public owners;
    uint256 public threshold = 1;
    uint256 public saltNonce = 12345;

    function setUp() public override {
        super.setUp();

        //awalys sort

        owners = new address[](2);
        owners[0] = vm.addr(2);
        owners[1] = vm.addr(1);

        owners = sortAddresses(owners);
    }

    function getProxySingleton(address proxy) internal view returns (address) {
        return IProxy(proxy).masterCopy();
    }

    function test_SafeCreation() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);

        assertTrue(
            safeAddress != address(0),
            "Safe address should not be zero"
        );

        // Use the interface method
        address proxySingleton = IProxy(safeAddress).masterCopy();

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

    function test_addOwnerWithThreshold() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);

        Safe safe = Safe(payable(safeAddress));
        address newOwner = vm.addr(3);
        vm.startPrank(address(safe));
        safe.addOwnerWithThreshold(newOwner, 2); // 3 owners two confirmations
        safe.getThreshold();
        vm.stopPrank();
    }

    function test_removeOwner() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);
        Safe safe = Safe(payable(safeAddress));
        vm.startPrank(address(safe));
        safe.removeOwner(owners[0], owners[1], 1);

        assertEq(safe.getOwners().length, 1);
    }

    function test_setGuard() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);
        Safe safe = Safe(payable(safeAddress));

        SimpleGuard guard = new SimpleGuard(); // create gurad contract

        vm.startPrank(address(safe));
        safe.setGuard(address(guard));

        vm.stopPrank();
    }

    function test_execTransaction() public {
        address safeAddress = createSafe(owners, threshold, saltNonce);
        Safe safe = Safe(payable(safeAddress));
        vm.deal(address(safe), 1 ether);

        address recipient = makeAddr("recipient");
        uint256 sendAmount = 1 ether;

        bytes32 txHash = safe.getTransactionHash(
            recipient,
            sendAmount,
            "",
            Enum.Operation.Call,
            100000,
            0,
            0,
            address(0),
            payable(address(0)),
            safe.nonce()
        );

        bytes memory signatures = buildSignatures(txHash);

        uint256 balanceBefore = recipient.balance;

        SimpleGuard guard = new SimpleGuard(); // Optional post and pre check  but required for tight seceurty or large funds withdrawl
        vm.startPrank(address(safe));
        safe.setGuard(address(guard));

        bool success = safe.execTransaction(
            recipient,
            sendAmount,
            "",
            Enum.Operation.Call,
            100000,
            0,
            0,
            address(0),
            payable(address(0)),
            signatures
        );

        require(success, "Transaction execution failed");
        assertEq(recipient.balance, balanceBefore + sendAmount);
    }

    function buildSignatures(
        bytes32 txHash
    ) internal pure returns (bytes memory) {
        bytes memory sigs;

        // Owner 1
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, txHash);
        sigs = abi.encodePacked(sigs, r1, s1, v1);

        // Owner 2
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, txHash);
        sigs = abi.encodePacked(sigs, r2, s2, v2);

        return sigs;
    }

    //  sorted address are required for signature decoding
    function sortAddresses(
        address[] memory arr
    ) internal pure returns (address[] memory) {
        uint256 n = arr.length;
        for (uint256 i = 0; i < n; i++) {
            for (uint256 j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    // Swap
                    address temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }
        return arr;
    }
}

/*
-------------------------------------------------------------------------------------------------+------------╮
| Method                                                                                          | Identifier |
+==============================================================================================================+
| VERSION()                                                                                       | ffa1ad74   |
|-------------------------------------------------------------------------------------------------+------------|
| addOwnerWithThreshold(address,uint256)                                                          | 0d582f13   |
|-------------------------------------------------------------------------------------------------+------------|
| approveHash(bytes32)                                                                            | d4d9bdcd   |
|-------------------------------------------------------------------------------------------------+------------|
| approvedHashes(address,bytes32)                                                                 | 7d832974   |
|-------------------------------------------------------------------------------------------------+------------|
| changeThreshold(uint256)                                                                        | 694e80c3   |
|-------------------------------------------------------------------------------------------------+------------|
| checkNSignatures(address,bytes32,bytes,uint256)                                                 | 1fcac7f3   |
|-------------------------------------------------------------------------------------------------+------------|
| checkNSignatures(bytes32,bytes,bytes,uint256)                                                   | 12fb68e0   |
|-------------------------------------------------------------------------------------------------+------------|
| checkSignatures(address,bytes32,bytes)                                                          | f855438b   |
|-------------------------------------------------------------------------------------------------+------------|
| checkSignatures(bytes32,bytes,bytes)                                                            | 934f3a11   |
|-------------------------------------------------------------------------------------------------+------------|
| disableModule(address,address)                                                                  | e009cfde   |
|-------------------------------------------------------------------------------------------------+------------|
| domainSeparator()                                                                               | f698da25   |
|-------------------------------------------------------------------------------------------------+------------|
| enableModule(address)                                                                           | 610b5925   |
|-------------------------------------------------------------------------------------------------+------------|
| execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)      | 6a761202   |
|-------------------------------------------------------------------------------------------------+------------|
| execTransactionFromModule(address,uint256,bytes,uint8)                                          | 468721a7   |
|-------------------------------------------------------------------------------------------------+------------|
| execTransactionFromModuleReturnData(address,uint256,bytes,uint8)                                | 5229073f   |
|-------------------------------------------------------------------------------------------------+------------|
| getModulesPaginated(address,uint256)                                                            | cc2f8452   |
|-------------------------------------------------------------------------------------------------+------------|
| getOwners()                                                                                     | a0e67e2b   |
|-------------------------------------------------------------------------------------------------+------------|
| getStorageAt(uint256,uint256)                                                                   | 5624b25b   |
|-------------------------------------------------------------------------------------------------+------------|
| getThreshold()                                                                                  | e75235b8   |
|-------------------------------------------------------------------------------------------------+------------|
| getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256) | d8d11f78   |
|-------------------------------------------------------------------------------------------------+------------|
| isModuleEnabled(address)                                                                        | 2d9ad53d   |
|-------------------------------------------------------------------------------------------------+------------|
| isOwner(address)                                                                                | 2f54bf6e   |
|-------------------------------------------------------------------------------------------------+------------|
| nonce()                                                                                         | affed0e0   |
|-------------------------------------------------------------------------------------------------+------------|
| removeOwner(address,address,uint256)                                                            | f8dc5dd9   |
|-------------------------------------------------------------------------------------------------+------------|
| setFallbackHandler(address)                                                                     | f08a0323   |
|-------------------------------------------------------------------------------------------------+------------|
| setGuard(address)                                                                               | e19a9dd9   |
|-------------------------------------------------------------------------------------------------+------------|
| setModuleGuard(address)                                                                         | e068df37   |
|-------------------------------------------------------------------------------------------------+------------|
| setup(address[],uint256,address,bytes,address,address,uint256,address)                          | b63e800d   |
|-------------------------------------------------------------------------------------------------+------------|
| signedMessages(bytes32)                                                                         | 5ae6bd37   |
|-------------------------------------------------------------------------------------------------+------------|
| simulateAndRevert(address,bytes)                                                                | b4faba09   |
|-------------------------------------------------------------------------------------------------+------------|
| swapOwner(address,address,address)                                                              | e318b52b   |
╰-------------------------------------------------------------------------------------------------+------------╯



 */
