// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// detects what Interfaces a smart contract implements

/* -> why neccessary means when a person accedently send a token to
 a contract and that does not support that same interface
 then the funds will stuck */

/* Example :
 Contract1 ask Contract2 do you support ERC721 ?
 if Contract2 responds with "YES" then the Contract1 will initiate the 
 tranfer, in case of "NO" the Contract1 must be aware of that the funds will 
 stuck in Contract2

 we can say that ERC165 works like a verfication of contract interface
*/

/*

For multiple tons of interfaces there must be unique or short way to 
check whether a contract supports an interface or not ?

so we create an identifier of the interface 

1) Keccake 
2) XOR operator


 */

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("NonFungibleTokens", "NFT") {
        // mint a few NFTs to myself during contract creation
        for (uint i = 0; i < 10; i++) {
            mintNFT(msg.sender, "");
        }
    }

    // get interfaceId for IERC165 (Standard Interface Detection)
    function getERC165InterfaceId() public pure returns (bytes4) {
        return type(IERC165).interfaceId;
    }

    // get interfaceId for IERC721 (Non-fungible tokens)
    function getERC721InterfaceId() public pure returns (bytes4) {
        return type(IERC721).interfaceId;
    }

    // get interfaceId for IERC721 Enumerable
    function getERC721EnumerableInterfaceId() public pure returns (bytes4) {
        return type(IERC721Enumerable).interfaceId;
    }

    // get interfaceId for onERC721Received(address,uint256,bytes)
    function getOnERC721ReceivedSelector() public pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // Call bytes4(keccak256) on a string.
    // You can pass in a method (and its argument types) to see what hash will be generated
    function getInterfaceId(
        string memory _function_signature
    ) public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(_function_signature)));
    }

    function mintNFT(
        address recipient,
        string memory tokenURI
    ) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
