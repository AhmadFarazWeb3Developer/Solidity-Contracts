// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Strings {
    string public myString; // slot 0x0
    uint256 public num; // slot 0x1

    // Shorts string (<= 31 bytes)

    // string data stored to left side and its lenght to right
    // if characters are 31 means it will take 62 hexes
    // lenght = 31 * 2 = 62 = 0x3e
    function the31BytesString() public returns (bytes32 content) {
        myString = "Learning Yul feels memory here.";

        assembly {
            content := sload(myString.slot) // 0x4c6561726e696e672059756c206665656c73206d656d6f727920686572652e3e
        }
    }
}

/* Strings are dynamic types meaning they dont have fixed size, 
Some string may fit within a single slot, while others may require multile slots.

String are stored in hex formate one character is one hex , means  bytes is two characters

*/
