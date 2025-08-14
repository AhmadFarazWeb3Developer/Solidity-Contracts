// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Implementation1} from "../src/Basic/Implementation1.sol";
import {Implementation2} from "../src/Basic/Implementation2.sol";

import {Proxy} from "../src/Basic/Proxy.sol";

import {ERC1967Proxy} from "../src/TransparentProxy/ERC1967Proxy.sol";
import {TransparentUpgradeableProxy} from "../src/TransparentProxy/TransparentUpgradeableProxy.sol";

import {ProxyAdmin} from "../src/TransparentProxy/ProxyAdmin.sol";

import {LogicMock} from "./mocks/LogicMock.sol";
import {UUPSLogicMock} from "./mocks/UUPSLogicMock.sol";

contract UtilsTest is Test {
    Implementation1 implementation1;
    Implementation2 implementation2;
    Proxy proxy;

    ERC1967Proxy erc1967Proxy;

    TransparentUpgradeableProxy transparentProxy;
    ProxyAdmin proxyAdmin;

    LogicMock logicContract;

    UUPSLogicMock uupsLogicMock;

    address admin = makeAddr("admin");

    function setUp() public virtual {
        // basic -----------------------------------------
        implementation1 = new Implementation1();
        implementation2 = new Implementation2();
        proxy = new Proxy();

        // transparent proxy -----------------------------

        logicContract = new LogicMock();
        vm.startPrank(admin);
        proxyAdmin = new ProxyAdmin();
        vm.stopPrank();
        bytes memory initializer = abi.encodeWithSignature(
            "Initializer(uint256)",
            1000
        );
        transparentProxy = new TransparentUpgradeableProxy(
            address(logicContract),
            address(proxyAdmin),
            initializer
        );

        uupsLogicMock = new UUPSLogicMock();

        erc1967Proxy = new ERC1967Proxy(
            address(uupsLogicMock),
            abi.encodeWithSelector(
                uupsLogicMock.initialize.selector,
                1000,
                "UUPS is pattern not proxy",
                admin
            )
        );
    }
}
