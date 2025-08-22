// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

contract BitsMasking {
    uint128 public C = 4;
    uint104 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    //  128 bits + 104 bits + 16 bits + 8 bits = 256 bits, slot is full

    function SlotData() external view returns (bytes32 slotValue) {
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

    function Mask() external view returns (bytes32 e, uint256 masked) {
        assembly {
            let slot := sload(E.slot) // load slot number
            e := shr(mul(E.offset, 8), slot) // shift E all its to right end
            masked := and(0xffff, e) // masking
        }

        /* Masking is a technique which keep some bits and throws rest means become 0s

        Mask: 0xffff = 1111 1111 1111 1111 

        0x0000000000000000000000000000000000000000000000000000000000010008 -hex
                                                                and 0xffff -hex
        
         binary 
          ...................................................0000 0000 0000 1000 (number)
                                                       and   1111 1111 1111 1111 (mask)
                                                             0000 0000 0000 1000
                                                               0    0    0    8  -> hex 
        
        
        // shr takes two argument bits to shift and slot number
        */
    }

    // now we want to update the slot of E with another value
    function writeE(
        uint16 _newE
    )
        external
        returns (
            bytes32 value,
            bytes32 clearedE,
            uint8 EOffset,
            bytes32 shifted,
            bytes32 newValue
        )
    {
        // for adding new value (e.g 10) we must delete the E value with bit masking

        assembly {
            value := sload(E.slot) // 0x0100080000000000000000000000000600000000000000000000000000000004
            clearedE := and(
                0xff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
                value
            ) // 0x0100000000000000000000000000000600000000000000000000000000000004
            EOffset := E.offset //  29 * 8 and place there 10
            shifted := shl(mul(E.offset, 8), _newE) // 0x00000a0000000000000000000000000000000000000000000000000000000000
            newValue := or(shifted, clearedE) // 0x01000a0000000000000000000000000600000000000000000000000000000004
            sstore(E.slot, newValue)

            /*
 AND OPERATION 
  0x 0100080000000000000000000000000600000000000000000000000000000004 = 0000 0001 0000 0000 0000 1000 ......0110....... 00000000000100
  0x ff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff = 1111 1111 0000 0000 0000 0000 ......1111....... 11111111111111
                                                                   AND  0000 0001 0000 0000 0000 0000 ......0110....... 00000000000100
                                                                          0    1    0    0    0   0   ...... 6 ........ 00000000000004

E bits are become empty


cleardE = 0x0100000000000000000000000000000600000000000000000000000000000004

shifted = 29 bytes = 2*29 hex = 58 are moved to left
            |
            v
    insert  10 = a  before 29 bytes
   0x 00000 4 0000000000000000000000000000000000000000000000000000000000
   0x 00000 a 0000000000000000000000000000000000000000000000000000000000 


OR operation 

   0x 00000 a 0000000000000000000000000000000000000000000000000000000000
   0x 01000 0 0000000000000000000000000600000000000000000000000000000004

     0000 0000 0000 0000 0000 1010 .................................0000
     0000 0001 0000 0000 0000 0000 ........ 0110....................0100
   =  0    1    0    0     0   a   ..........6.........................4 
   = 0x01000a0000000000000000000000000600000000000000000000000000000004

 */
        }
    }
}
