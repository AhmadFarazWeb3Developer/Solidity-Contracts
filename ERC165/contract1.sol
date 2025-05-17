// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./interface.sol";

contract Contract1 {
    function checkSupport(address other) external view returns (bool) {
        return IERC165(other).supportsInterface(type(Check).interfaceId);
    }
}
