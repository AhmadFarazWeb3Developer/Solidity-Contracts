// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

import {ITransparentUpgradeableProxy} from "../src/TransparentProxy/interfaces/ITransparentUpgradeableProxy.sol";
import {TransparentUpgradeableProxy} from "../src/TransparentProxy/TransparentUpgradeableProxy.sol";
import {LogicMock} from "./mocks/LogicMock.sol";

contract TransparentUpgradeableProxyTest is UtilsTest {
    function setUp() public override {
        UtilsTest.setUp();
    }

    modifier onlyAdmin() {
        vm.startPrank(admin);
        _;
    }

    function test_Proxy() public onlyAdmin {
        /**
         * We cast the proxy address to the LogicMock interface
         * so we can interact with it as if it were the logic contract.
         *
         * Example: When calling `proxyAsLogic.value()`:
         *   1. The call is sent to the proxy address.
         *   2. The proxy's fallback function receives the call.
         *   3. The proxy performs a delegatecall to the logic contract.
         *   4. The logic's code executes in the context of the proxy’s storage.
         *
         * Result:
         *   - State changes happen in the proxy’s storage, not in the logic contract.
         *   - Initialization data passed at deployment time set `value` to 1000.
         */
        LogicMock proxyAsLogic = LogicMock(address(transparentProxy));

        uint256 storedValue = proxyAsLogic.value();
        assertEq(
            storedValue,
            1000,
            "Initialization should have set value to 1000"
        );
    }

    function test_changeProxyAdmin() public onlyAdmin {
        /**
         * The ProxyAdmin contract is the actual admin of the TransparentUpgradeableProxy.
         * Since our `admin` address owns the ProxyAdmin, it can call `changeProxyAdmin()`,
         * which internally calls the proxy's `changeAdmin()` function.
         *
         * This will succeed because:
         *   - msg.sender (`admin`) is the owner of ProxyAdmin.
         *   - ProxyAdmin is the admin stored in the proxy's EIP-1967 admin slot.
         */
        proxyAdmin.changeProxyAdmin(
            ITransparentUpgradeableProxy(address(transparentProxy)),
            address(this)
        );
    }
}

