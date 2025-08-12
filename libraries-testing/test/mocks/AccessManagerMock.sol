// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AccessManager} from "../../src/AccessManager/AccessManager.sol";

contract AccessManagerMock is AccessManager {
    bytes32 public constant MINTER_ROLE = keccak256("Minter_Role");

    constructor(address _initialAdmin) AccessManager(_initialAdmin) {}

    function calledByAuthorized()
        public
        onlyAuthorized
        returns (string memory)
    {
        return "I am Authorized";
    }
}
