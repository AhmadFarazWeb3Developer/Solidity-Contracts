// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "../../src/UUPS_Upgradeable/UUPSUpgradeable.sol";

contract UUPSLogicMock is UUPSUpgradeable {
    uint256 public value;

    function Initializer(uint256 _value) public {
        value = _value;
    }
}
