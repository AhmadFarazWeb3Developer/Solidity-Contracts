// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PKBK is ERC20 {
    constructor(uint256 _intialSupply) ERC20("Pak Block", "pkbk") {
        _mint(msg.sender, _intialSupply);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}

// Address on sepolia testnet: 0xBc833cc77335639e7d340A1BfdDB0F18C2E480A7
