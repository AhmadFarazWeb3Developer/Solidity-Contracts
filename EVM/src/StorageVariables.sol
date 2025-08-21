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
    bool e; // defaults to false, take 1 byte, storage slot 0x1 (packed inot same slot-2)
    uint f; // default to 0, takes 32 bytes , storage slot 0x3,

    constructor() {
        // hex values at slots
        bytes32 slot1Val;
        bytes32 slot2Val;
        bytes32 slot3Val;

        uint256 x_slot;
        uint256 c_slot;
        uint256 d_slot;
        uint256 e_slot;
        uint256 f_slot;

        assembly {
            // Yul

            x_slot := a.slot
            c_slot := c.slot
            d_slot := d.slot
            e_slot := e.slot
            f_slot := f.slot

            slot1Val := sload(0x0)
            slot2Val := sload(0x1)
            slot3Val := sload(0x2)
        }

        console.logBytes32(slot1Val);
        console.logBytes32(slot2Val);
        console.logBytes32(slot3Val);
        console.log(x_slot);
        console.log(c_slot);
        console.log(d_slot);
        console.log(e_slot);
        console.log(f_slot);
    }
}
