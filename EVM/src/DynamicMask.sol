// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract BuildDynamicMask {
    function normalMask()
        public
        pure
        returns (
            bytes32 shifted,
            bytes32 mask1,
            bytes32 mask2,
            bytes32 mask3,
        )
    {
        assembly {
            shifted := shl(16, 1) // shift 1 to left with 16 bits

            // 0x0000000000000000000000000000000000000000000000000000000000010000
            //  00000000000000000000000000000000000 ......0001 0000 0000 0000 0000

            mask1 := sub(shl(16, 1), 1)

            //   0x0000000000000000000000000000000000000000000000000000000000010000 (shifted)
            //   0x0000000000000000000000000000000000000000000000000000000000000001 (sub 1)
            //   SUB
            // = 0x000000000000000000000000000000000000000000000000000000000000ffff (mask)

            // BITWISE CALCULATION
            //                                                        0001 0000 0000 0000 0000 -> borrow 1 makes each previous 0 to 10 = 2 then we cut it to 1 then LSB becomes 2
            //                                                        0000 0000 0000 0000 0001
            //                                                      = 0000 1111 1111 1111 1111
            //                                                      =  0    f     f    f    f

            mask2 := shl(32, sub(shl(16, 1), 1)) // 0x0000000000000000000000000000000000000000000000000000ffff00000000
            // 32 bits / 4 hex = 8 number of shifts in hex notation

            mask3 := not(sub(shl(128, 1), 1))
            //    128 bits / 4 hex = 32 shifts
            //    0x0000000000000000000000000000000100000000000000000000000000000000 -> shif
            //    0x0000000000000000000000000000000000000000000000000000000000000001 -> sub
            //    0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff -> new value
            //    0xffffffffffffffffffffffffffffffff00000000000000000000000000000000 -> not(p) flips bits
        }
    }
}
