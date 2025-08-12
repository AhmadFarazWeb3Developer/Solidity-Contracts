// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AccessControlDefaultAdminRules} from "../../src/extensions/AccessControlDefaultAdminRules.sol";

contract AccessControlDefaultAdminRulesMock is AccessControlDefaultAdminRules {
    bytes32 public constant MINTER_ROLE = keccak256("Minter_Role");

    constructor(
        uint48 _initialDelay,
        address _admin
    ) AccessControlDefaultAdminRules(_initialDelay, _admin) {}

    function calledByMinter()
        public
        view
        onlyRole(MINTER_ROLE)
        returns (string memory)
    {
        return "I am Minter";
    }
}
