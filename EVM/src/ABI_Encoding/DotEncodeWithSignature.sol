// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

/*

The function signature is the combination of the function name and its argument types without spaces.

If we were to make a low level call to another smart contract with a public function foo(uint256 x) (passing x = 5 as the argument), we would do the following:
otherContractAddr.call(abi.encodeWithSignature("foo(uint256)", (5)); */
//
contract DotEncodeWithSignature {
    function EnodeSignature() external pure returns (bytes memory) {
        return abi.encodeWithSignature("foo(uint256)", 5);
        // 0x2fbebd38 -> 4 bytes of keccake256 of function
        // 0000000000000000000000000000000000000000000000000000000000000005
    }

    /*
    This data for the function call isn’t stored permanently within the function or the contract itself. 
    Instead, it lives in a space called “calldata.” You cannot modify the data in calldata, as it’s created by the transaction sender and then becomes read-only.
     */

    /*
    Calldata:
    - Temporary, read-only space where function arguments are stored at runtime.
    - Created by the transaction/call sender, and passed into the function.
    - Cheaper than memory because it is not modifiable.
    - Used by external/public functions to access their inputs.
    - If you need to change the arguments, copy them into "memory".
*/

    function execute(address target, bytes calldata actionData) public pure {
        /* 
        0x00..0x03 : execute.selector
        0x04..0x23 : target (0x2d1d989a...)
        0x24..0x43 : pointer to actionData (e.g. 0x40)
        0x40..0x5f : length of actionData (0x60)
        0x60..0x9f : 0x844b4cf9...dd9b878e...
        0xa0..0xdf : 0x2d1d989a...    
      */
    }
}
