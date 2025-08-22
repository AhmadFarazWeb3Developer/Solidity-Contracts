// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {Test, console} from "forge-std/Test.sol";
contract TypeError {
    
    address public owner = 0xC257274276a4E539741Ca11b590B9447B26A8051;

    function TypeErrorNotImplicitlyConvertible(uint256 _value) external {
        // @>   owner = _value;      // Compile time error Type uint256 is not implicitly convertible to expected type address.
    }

    function sstoreHasNoTypeCheck(uint256 _value) public {
        uint256 slotOldValue;
        uint256 slotNewValue;
        assembly {
            slotOldValue := sload(0x0)
            sstore(owner.slot, _value)
            slotNewValue := sload(0x0)
        }

        console.log(slotOldValue);
        console.log(slotNewValue);
    }
}
