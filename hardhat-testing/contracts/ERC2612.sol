// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC2612 is ERC20, ERC20Permit {
    constructor(
        uint256 _initialSupply
    ) ERC20("My Token", "MYTK") ERC20Permit("My Token") {
        _mint(msg.sender, _initialSupply);
    }
}
