// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ERC165_DEMO.sol";

contract Contract2 is ERC165_DEMO {
    string public World;
    uint public Value;

    function hello() external override {
        World = "World";
    }

    function world(uint _value) external override {
        Value = _value;
    }
}
