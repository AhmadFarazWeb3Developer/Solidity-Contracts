// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract BuildDynamicMask {
    uint128 public A = 1000;
    uint104 public B = 24;
    uint16 public C = 9;
    uint8 public D = 3;

    string public str = "Yul";

    function normalMask()
        public
        pure
        returns (bytes32 shifted, bytes32 mask1, bytes32 mask2, bytes32 mask3)
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

    function YulStr() public view returns (bytes32 slot, bytes32 content) {
        assembly {
            slot := str.slot
            content := sload(str.slot) // 0x59756c0000000000000000000000000000000000000000000000000000000006
        }
    }

    function dynamicMaskForUint(
        string memory _symbol,
        uint256 _value
    ) external {
        uint128 A_value;
        uint104 B_value;
        uint16 C_value;
        uint8 D_value;

        if (bytes(_symbol).length > 1 || bytes(_symbol).length == 0) {
            revert("Ony single character is allowed");
        } else {
            if (
                keccak256(abi.encodePacked(_symbol)) ==
                keccak256(abi.encodePacked("A"))
            ) {
                A_value = uint128(_value);
            } else if (
                keccak256(abi.encodePacked(_symbol)) ==
                keccak256(abi.encodePacked("B"))
            ) {
                B_value = uint104(_value);
            } else if (
                keccak256(abi.encodePacked(_symbol)) ==
                keccak256(abi.encodePacked("C"))
            ) {
                C_value = uint16(_value);
            } else if (
                keccak256(abi.encodePacked(_symbol)) ==
                keccak256(abi.encodePacked("D"))
            ) {
                D_value = uint8(_value);
            } else {
                revert("Did'nt match");
            }

            assembly {

            }
        }
    }

    // function Yul(string memory symbol) public pure returns (bytes32) {
    //     return keccak256(abi.encodePacked(symbol));
    // }
}
