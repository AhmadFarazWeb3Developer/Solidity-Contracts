// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AccessControl} from "../../src/AccessControl/AccessControl.sol";

contract AccessControlMock is AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("Minter_Role");
    bytes32 public constant TEMPORARY_ROLE = keccak256("Temprory_Role");

    constructor(address _admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }
}
