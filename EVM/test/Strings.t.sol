// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract StringsTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    function test_31BytesString() public {
        strings.the31BytesString();

        string memory str = strings.myString();
        console.log(bytes(str).length);
    }
    function test_31PlusBytesString() public {
        strings.the31PlusBytesString();

        // storage slot : 0x0000000000000000000000000000000000000000000000000000000000000000
        // storage slot data :  0x0000000000000000000000000000000000000000000000000000000000000061
        // slot just store the length of the string

        // data are place from this slot
        bytes32 dataSlot = keccak256(
            abi.encode(
                0x0000000000000000000000000000000000000000000000000000000000000000
            )
        );

        // for checking where over data in slots are, we must know how many bytes and slots we have consumned for storing the myString

        // string length (0x61 - 1) / 2; // 48 bytes

        // 32 bytes + 16 bytes
        bytes32 slotX = vm.load(address(strings), dataSlot); // 0x492062726561746820426c6f636b636861696e2c20736f6c696469747920616e
        bytes32 slotXPlusOne = vm.load(
            address(strings),
            bytes32(uint256(dataSlot) + 1)
        ); // 0x64207370656361696c6c792059756c2e00000000000000000000000000000000

        bytes memory fullString = abi.encodePacked(
            slotX,
            bytes16(slotXPlusOne)
        ); //

        string memory myString = string(fullString);
        console.log(myString);
    }
}
