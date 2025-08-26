// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CallData {
    // A function that takes an immutable array as calldata
    function processArray(
        uint256[] calldata inputArray
    ) external pure returns (uint256) {
        uint256 sum = 0;

        // Iterate over the array to compute the sum
        for (uint256 i = 0; i < inputArray.length; i++) {
            sum += inputArray[i];
        }

        return sum;
    }

    // A function that accepts a single string as calldata
    function echoMessage(
        string calldata message
    ) external pure returns (string memory) {
        return message; // Simply return the input message
    }

    // Function that takes an array as calldata
    function modifyArray(
        uint256[] calldata inputArray
    ) external pure returns (uint256[] memory) {
        // Attempting to modify a calldata parameter - This will cause a compilation error
        inputArray[0] = 42; //  Error: calldata is immutable and cannot be modified

        // To fix this, the developer would need to copy the calldata into memory
        return inputArray;
    }
}

/*
calldata is a non-modifiable, temporary, read-only data location, primarily used for storing function arguments passed during external calls in the Ethereum Virtual Machine (EVM). It is used to handle input data for external function calls in smart contracts. 

Unlike other data locations like memory and storage, calldata is optimized for efficiency. It is particularly useful for lightweight data that doesn’t require modifications or long-term storage.


Examples of how calldata is used:
 -> Passing large arrays in external calls: Using calldata for large arrays avoids the gas costs of copying data into memory, making the transaction less expensive to execute.
 -> Immutable input for security: calldata ensures inputs, such as digital signatures, remain immutable and secure from tampering during execution.
 -> Read-only data for efficiency: Functions that only read data, like fetching user details, can use calldata to reduce gas costs.
 -> Temporary input in stateless functions: Stateless functions, such as hash functions or sum calculations, use calldata for temporary inputs without incurring storage costs.
 -> Oracles or external data feeds: Smart contracts using Oracles (e.g., price feeds) rely on calldata for gas-efficient, immutable data handling.




 */
