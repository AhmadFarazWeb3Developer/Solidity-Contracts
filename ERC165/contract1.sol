// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ERC165_DEMO.sol";

contract Contract1 {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function calculateSelector() public pure returns (bytes4) {
        return ERC165_DEMO.hello.selector ^ ERC165_DEMO.world.selector;
    }

    function containsSelector(bytes4 selector) public view returns (bool) {
        bytes memory code = target.code;

        for (uint i = 0; i < code.length - 4; i++) {
            bytes4 sig;
            assembly {
                sig := mload(add(add(code, 0x20), i))
            }
            if (sig == selector) {
                return true;
            }
        }

        return false;
    }

    function implementsERC165_DEMO() external view returns (bool) {
        return
            containsSelector(ERC165_DEMO.hello.selector) &&
            containsSelector(ERC165_DEMO.world.selector);
    }
}
