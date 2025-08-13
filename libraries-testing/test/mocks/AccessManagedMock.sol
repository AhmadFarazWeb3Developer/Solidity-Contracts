// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AccessManaged} from "../../src/AccessManager/AccessManaged.sol";

contract AccessManagedMock is AccessManaged {
    constructor(address _initialAuthoriy) AccessManaged(_initialAuthoriy) {}

    function calledByAuthorized() public restricted returns (string memory) {
        return "I am Authorized";
    }
}
