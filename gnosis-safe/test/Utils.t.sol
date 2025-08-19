// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Safe} from "../src/Safe.sol";
import {SingletonFactory} from "../src/SingletonFactory.sol";
import {SafeProxyFactory} from "../src/proxies/SafeProxyFactory.sol";
import {SafeProxy} from "../src/proxies/SafeProxy.sol";
import {CompatibilityFallbackHandler} from "../src/handler/extensible/CompatibilityFallbackHandler.sol";

abstract contract UtilsTest is Test {
    SingletonFactory public singletonFactory;
    SafeProxyFactory public proxyFactory;
    Safe public singleton;
    CompatibilityFallbackHandler public fallbackHandler;

    function setUp() public virtual {
        vm.deal(address(this), 100 ether);

        // 1. Deploy SingletonFactory
        singletonFactory = new SingletonFactory();

        // 2. Deploy Safe singleton
        bytes memory safeInitCode = type(Safe).creationCode;
        bytes32 safeSalt = keccak256("GnosisSafeDeployment");
        address singletonAddress = singletonFactory.deploy(
            safeInitCode,
            safeSalt
        );
        singleton = Safe(payable(singletonAddress));

        // 3. Deploy ProxyFactory
        bytes memory factoryInitCode = type(SafeProxyFactory).creationCode;

        bytes32 factorySalt = keccak256("GnosisSafeProxyFactoryDeployment");
        address factoryAddress = singletonFactory.deploy(
            factoryInitCode,
            factorySalt
        );
        proxyFactory = SafeProxyFactory(factoryAddress);

        // 4. Deploy FallbackHandler
        bytes memory handlerInitCode = type(CompatibilityFallbackHandler)
            .creationCode;
        bytes32 handlerSalt = keccak256("GnosisSafeFallbackHandlerDeployment");
        address handlerAddress = singletonFactory.deploy(
            handlerInitCode,
            handlerSalt
        );
        fallbackHandler = CompatibilityFallbackHandler(handlerAddress);
    }

    function createSafe(
        address[] memory owners,
        uint256 threshold,
        uint256 saltNonce
    ) public returns (address) {
        vm.deal(address(this), 100 ether);
        // vm.prank(vm.addr(1));

        bytes memory initializer = abi.encodeWithSignature(
            "setup(address[],uint256,address,bytes,address,address,uint256,address)",
            owners,
            threshold,
            address(0), // to
            bytes(""), // data
            address(fallbackHandler), // fallback handler
            address(0), // paymentToken
            0, // payment
            address(0) // paymentReceiver
        );

        SafeProxy proxy = proxyFactory.createProxyWithNonce(
            address(singleton),
            initializer,
            saltNonce
        );

        vm.deal(address(proxy), 1 ether);
        return address(proxy);
    }
}
