// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/*

abi.encodeWithSelector is more gas-efficient since the selector is already computed

*/
contract DotEncodeWithSelector {
    // using IERC20 for token;
    address dummyAddress = 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a;
    function EncodeWithSelector() public view returns (bytes memory) {
        return
            abi.encodeWithSelector(
                IERC20.transfer.selector,
                dummyAddress,
                1000 ether
            );
    }
}
