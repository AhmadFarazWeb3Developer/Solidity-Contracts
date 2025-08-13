// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Proxy holds storage state

contract Proxy {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        require(success, "Delegation call failed");
    }
}
