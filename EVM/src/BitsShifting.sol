// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

contract BitsShifting {
    uint256 public a = 8; //  000.... 00001000 = 8
    uint256 public b = a >> 1; // 000....00000100 = 4
    uint256 public c = b << 3; // 000....00100000

    // Conversions between datatypes

    uint256 public x = 256; // it can hold 2**256
    uint8 public y = uint8(x); // it can hold 2**8  = 256 number, 0 to 255

    function storageLayout()
        external
        returns (bytes32 a_slotValue, bytes32 b_slotValue, bytes32 c_slotValue)
    {
        assembly {
            a_slotValue := sload(0x0)
            b_slotValue := sload(0x1)
            c_slotValue := sload(0x2)
        }
    }
}
