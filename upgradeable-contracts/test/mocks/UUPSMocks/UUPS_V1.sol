// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "../../../src/UUPS_Upgradeable/UUPSUpgradeable.sol";
import {Initializable} from "../../../src/UUPS_Upgradeable/Initializable.sol";
import {OwnableUpgradeable} from "../../../src/UUPS_Upgradeable/access/OwnableUpgradeable.sol";

contract UUPS_V1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public value;
    string public name;

    event ValueUpdated(uint256 newValue);
    event NameUpdated(string newName);

    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 _initialValue,
        string memory _name,
        address _owner
    ) public initializer {
        __Ownable_init(_owner);
        value = _initialValue;
        name = _name;

        emit ValueUpdated(_initialValue);
        emit NameUpdated(_name);
    }

    // missing this function will permanently block the upgrades
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // Business logic functions
    function setValue(uint256 _newValue) external {
        value = _newValue;
        emit ValueUpdated(_newValue);
    }

    function setName(string memory _newName) external onlyOwner {
        name = _newName;
        emit NameUpdated(_newName);
    }

    // Version tracking (recommended)
    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}
