// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "../../src/UUPS_Upgradeable/UUPSUpgradeable.sol";
import {Initializable} from "../../src/UUPS_Upgradeable/Initializable.sol";
import {OwnableUpgradeable} from "../../src/UUPS_Upgradeable/access/OwnableUpgradeable.sol";

// FIXED VERSION OF YOUR CONTRACT
contract UUPSLogicMock is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public value;
    string public name;

    // Events for better tracking
    event ValueUpdated(uint256 newValue);
    event NameUpdated(string newName);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // FIXED: Function name should be lowercase 'initialize', not 'Initialize'
    // FIXED: Must include 'initializer' modifier
    // FIXED: Parameter name mismatch (_value vs _initialValue)
    // FIXED: Missing assignment for name
    function initialize(
        uint256 _initialValue,
        string memory _name,
        address _owner
    ) public initializer {
        // Initialize parent contracts
        __Ownable_init(_owner);
        // UUPSUpgradeable doesn't need explicit init in newer versions

        // Set initial values
        value = _initialValue; // FIXED: was _value, should be _initialValue
        name = _name; // FIXED: was missing this assignment

        // Emit events
        emit ValueUpdated(_initialValue);
        emit NameUpdated(_name);
    }

    // MANDATORY: Must implement _authorizeUpgrade for UUPS
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {
        // Only owner can upgrade
        // Additional validation logic can go here if needed
    }

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
