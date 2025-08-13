// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract AuthorityMock {
    mapping(address => bool) public authorized;

    function setAuthorized(address user, bool status) external {
        authorized[user] = status;
    }

    function canCall(
        address caller,
        address target,
        bytes4 selector
    ) external view returns (bool) {
        return true;
    }
}
