// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Implementation2 {
    // lets new version is released and the proxy storage is old one,
    // keep in mind the proxy storage layout expands automatically,
    // but new storage slot cannot be accessed directly via like proxy.newFeature()

    uint256 public num;
    address public sender;
    uint256 public value;
    uint256 public newFeature; // new slot added

    function setVars(uint256 _num) public payable {
        sender = msg.sender;
        value = msg.value;

        newFeature = 10000;

        num = _num * newFeature;
    }
}
