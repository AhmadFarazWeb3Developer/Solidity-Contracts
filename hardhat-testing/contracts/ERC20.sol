// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PKBK is ERC20 {
    constructor(uint256 _initialSupply) ERC20("Pak Block", "pkbk") {
        _mint(msg.sender, _initialSupply);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
