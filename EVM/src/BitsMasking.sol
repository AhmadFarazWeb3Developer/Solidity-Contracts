// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

contract BitsMasking {
    uint128 public C = 4;
    uint104 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    //  128 bits + 104 bits + 16 bits + 8 bits = 256 bits, slot is full

    function SlotData() external returns (bytes32 slotValue) {
        // 0x0100080000000000000000000000000600000000000000000000000000000004
        assembly {
            slotValue := sload(0x0)
        }
    }

    // The issue is how we will extract data of our interest ?
    // now the offset comes into use

    // lets want to extrat `E` value.

    function getOffSet() external pure returns (uint8 offset) {
        //        |
        //        V
        // 0x0100080000000000000000000000000600000000000000000000000000000004

        // returns 29, its means the variables is 29 bits left

        assembly {
            offset := E.offset
        }
    }

    function startShifting() external returns (bytes32 e) {
        assembly {
            let slot := sload(E.slot) // load slot number
            e := shr(mul(E.offset, 8), slot) // 0x0000000000000000000000000000000000000000000000000000000000010008
        }
        // shr takes two argument bits to shift and slot number
    }
}
