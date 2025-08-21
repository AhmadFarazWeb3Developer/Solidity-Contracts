// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract ConstantIsNotOnStorage {
    uint256 constant VALUE = 1000; // this is placed directly to bytecode , not in storge

    // if it was on storage i will must have thrown compilation error
    function readConstant() public pure returns (uint256) {
        return VALUE;
    }
}
