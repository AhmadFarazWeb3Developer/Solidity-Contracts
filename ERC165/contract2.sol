// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./interface.sol";

contract Contract2 is Check {
    uint value = 100;

    function ShouldImplement(uint _Value) public view returns (uint) {
        return value + _Value;
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == type(Check).interfaceId;
    }
}
