// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// its for the recepient contracts not the wallets

interface IERC721Receiver {
    // recepient contract must implement this function otherwise the safeTransferFrom will fail
    function onERC721Received(
        address operator,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
