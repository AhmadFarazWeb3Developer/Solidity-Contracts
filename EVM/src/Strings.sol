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

    function the31PlusBytesString()
        public
        returns (bytes32 slot, bytes32 content)
    {
        myString = "I breath Blockchain, solidity and specailly Yul."; // 48 bytes
        // 32 bytes + 16 bytes, cover 1 and half slots
        assembly {
            slot := myString.slot
            content := sload(myString.slot) // the length of content in slot, because bytes > 31

            /* 
            The content are stored are keccake256(slot):
            slot    0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563 = 0x492062726561746820426c6f636b636861696e2c20736f6c696469747920616e
            slot+1  0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e564 = 0x64207370656361696c6c792059756c2e00000000000000000000000000000000
            */
        }
    }
}

/* Strings are dynamic types meaning they dont have fixed size, 
Some string may fit within a single slot, while others may require multile slots.

String are stored in hex formate one character is one hex , means  bytes is two characters

*/
