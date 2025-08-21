// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract StorageVariables {
    // all empty values default to 0x0, i.e., 0x....000000
    // max value in hex would be 0xfffff....fff

    uint256 a = 10000000000000000; // storage slot 0x0 (slot-1)
    uint256 constant b = 10; // goes to contract byte code direcly not slots.
    uint8 c = 5; // storage slot 0x1 (packed into the same slot-2)
    uint16 d = 10; // storage slot 0x1 (packed into the same slot-2)

    bool e; // defaults to false, HEX value would be 0x....0000 (64 characters)
    uint f; // storage slot 0x3

    constructor() {
        bytes32 slot1Val;
        bytes32 slot2Val;
        bytes32 slot3Val;
        bytes32 slot4Val;
        bytes32 slot5Val;
        assembly {
            slot1Val := sload(0x0)
            slot2Val := sload(0x1)
            slot3Val := sload(0x2)
            slot4Val := sload(0x3)
            slot5Val := sload(0x4)
        }

        console.logBytes32(slot1Val);
        console.logBytes32(slot2Val);
        console.logBytes32(slot3Val);
        console.logBytes32(slot4Val);
        console.logBytes32(slot5Val);
    }
}
