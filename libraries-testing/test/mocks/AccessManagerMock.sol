// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AccessManager} from "../../src/AccessManager/AccessManager.sol";

contract AccessManagerMock is AccessManager {
    constructor(address _initialAdmin) AccessManager(_initialAdmin) {}

    function calledByAuthorized()
        public
        onlyAuthorized
        returns (string memory)
    {
        return "I am Authorized";
    }
}
