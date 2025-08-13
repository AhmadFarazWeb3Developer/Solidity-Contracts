// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Implementation1 {
    // Note storage layout must be the same as contract A,
    // solidity knows the storage indexes not the name of vars

    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}
