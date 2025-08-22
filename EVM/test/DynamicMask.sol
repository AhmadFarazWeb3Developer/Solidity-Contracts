// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract BuildDynamicMaskTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_normalMask() public view {
        dynamicMask.normalMask();
    }
    function test_YulStr() public view {
        dynamicMask.YulStr();
    }

    function test_YulA() public view {
        //   assertEq(dynamicMask.Yul("A"), keccak256(abi.encodePacked("A")));
        // 0x03783fac2efed8fbc9ad443e592ee30e61d65f471140c10ca155e937b435b760
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
