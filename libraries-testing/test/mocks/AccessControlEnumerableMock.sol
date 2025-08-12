// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import {AccessControl} from "../../src/AccessControl/AccessControl.sol";
import {AccessControlEnumerable} from "../../src/extensions/AccessControlEnumerable.sol";

contract AccessControlEnumerableMock is AccessControlEnumerable {
    
    bytes32 public constant MINTER_ROLE = keccak256("Minter_Role");

    constructor(address _admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function calledByMinter()
        public
        view
        onlyRole(MINTER_ROLE)
        returns (string memory)
    {
        return "I am Minter";
    }
}
