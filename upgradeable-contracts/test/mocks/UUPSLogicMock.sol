// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "../../src/UUPS_Upgradeable/UUPSUpgradeable.sol";
import {Initializable} from "../../src/UPS_Upgradeable/Initializable.sol";

contract UUPSLogicMock is UUPSUpgradeable, Initializable {

    uint256 public value;






    function Initializer(uint256 _value) public {
        value = _value;
    }
}
