// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UUPSUpgradeable} from "../../../src/UUPS_Upgradeable/UUPSUpgradeable.sol";
import {Initializable} from "../../../src/UUPS_Upgradeable/Initializable.sol";
import {OwnableUpgradeable} from "../../../src/UUPS_Upgradeable/access/OwnableUpgradeable.sol";

contract UUPS_V2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(address => uint256) balances;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _owner) public reinitializer(2) {
        __Ownable_init(_owner);

        balances[msg.sender] = 0;
    }
    // missing this function will permanently block the upgrades
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function setBalance(uint256 _balance) external onlyOwner {
        balances[msg.sender] = _balance;
    }

    function version() external pure returns (string memory) {
        return "2.0.0";
    }
}
