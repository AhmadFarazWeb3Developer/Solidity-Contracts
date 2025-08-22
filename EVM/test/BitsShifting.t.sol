// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract BitsShiftingTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_values() public {
        bitsShifting.a(); // 8
        bitsShifting.b(); // 4
        bitsShifting.c(); // 32

        // type convert values
        bitsShifting.x(); // 256
        bitsShifting.y(); // 0
    }

    function test_storageLayout() public {
        bitsShifting.storageLayout();
        // slot0 : 0x0000000000000000000000000000000000000000000000000000000000000008
        // slot1 : 0x0000000000000000000000000000000000000000000000000000000000000004
        // slot2 : 0x0000000000000000000000000000000000000000000000000000000000000020
    }
}

/*

| Decimal | 8-bit Binary | Hex  |
| ------- | ------------ | ---- |
| 0       | `00000000`   | 0x00 |
| 1       | `00000001`   | 0x01 |
| 2       | `00000010`   | 0x02 |
| 3       | `00000011`   | 0x03 |
| 4       | `00000100`   | 0x04 |
| 5       | `00000101`   | 0x05 |
| 6       | `00000110`   | 0x06 |
| 7       | `00000111`   | 0x07 |
| 8       | `00001000`   | 0x08 |
| 9       | `00001001`   | 0x09 |
| 10      | `00001010`   | 0x0A |
| 11      | `00001011`   | 0x0B |
| 12      | `00001100`   | 0x0C |
| 13      | `00001101`   | 0x0D |
| 14      | `00001110`   | 0x0E |
| 15      | `00001111`   | 0x0F |
| 16      | `00010000`   | 0x10 |

 */
