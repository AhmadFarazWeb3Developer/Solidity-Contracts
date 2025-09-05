// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Utils} from "./Utils.t.sol";
contract GameTest is Utils {
    function setUp() public override {
        super.setUp();
    }

    function test_balances() public {
        game.balanceOf(minter, 0);
        game.balanceOf(minter, 1);
        game.balanceOf(minter, 2);
        game.balanceOf(minter, 3);
        game.balanceOf(minter, 4);
    }

    function test_Uri() public {
        game.uri(0);
        game.uri(1);
        game.uri(2);
        game.uri(3);
    }

    function test_Ids() public {
        game.GOLD();
        game.SILVER();
        game.THORS_HAMMER();
        game.SWORD();
        game.SHIELD();
    }

    function test_safeTransferFrom() public {
        address recepient = makeAddr("recepient");
        vm.startPrank(minter);
        game.safeTransferFrom(minter, recepient, 0, 1 ether, ""); // data is passed if the recevier is contract and must implement ERC1155Receiver

        assertEq(game.balanceOf(minter, 0), 0);
        assertEq(game.balanceOf(recepient, 0), 1 ether);
    }

    function test_safeBatchTransferFrom() public {
        address recepient = makeAddr("recepient");
        vm.startPrank(minter);

        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);

        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = i;
        }

        amounts[0] = 1 ether;
        amounts[1] = 2 ether;
        amounts[2] = 1;
        amounts[3] = 1e9;
        amounts[4] = 1e9;

        game.safeBatchTransferFrom(minter, recepient, ids, amounts, "");

        address[] memory accounts = new address[](5);
        for (uint256 i = 0; i < ids.length; i++) {
            accounts[i] = recepient;
        }
        game.balanceOfBatch(accounts, ids);
    }

    function test_setApprovalForAll(address, bool) public {
        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);

        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = i;
        }

        amounts[0] = 1 ether;
        amounts[1] = 2 ether;
        amounts[2] = 1;
        amounts[3] = 1e9;
        amounts[4] = 1e9;

        address recepient = makeAddr("recepient"); // tokens will be sent to receipient
        address operator = makeAddr("operator"); // this will send on behalf of minter

        vm.startPrank(minter);
        game.setApprovalForAll(operator, true);
        vm.stopPrank();

        vm.startPrank(operator);
        game.safeBatchTransferFrom(minter, recepient, ids, amounts, "");
        vm.stopPrank();

        address[] memory accounts = new address[](5);
        for (uint256 i = 0; i < ids.length; i++) {
            accounts[i] = recepient;
        }

        game.balanceOfBatch(accounts, ids);
    }
}

/**
 
╭------------------------------------------------------------------+------------╮
| Method                                                           | Identifier |
+===============================================================================+
| GOLD()                                                           | 3e4bee38   |
|------------------------------------------------------------------+------------|
| SHIELD()                                                         | 5b2725ed   |
|------------------------------------------------------------------+------------|
| SILVER()                                                         | e3e55f08   |
|------------------------------------------------------------------+------------|
| SWORD()                                                          | 13dc989f   |
|------------------------------------------------------------------+------------|
| THORS_HAMMER()                                                   | d562e204   |
|------------------------------------------------------------------+------------|
| balanceOf(address,uint256)                                       | 00fdd58e   |
|------------------------------------------------------------------+------------|
| balanceOfBatch(address[],uint256[])                              | 4e1273f4   |
|------------------------------------------------------------------+------------|
| isApprovedForAll(address,address)                                | e985e9c5   |
|------------------------------------------------------------------+------------|
| safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) | 2eb2c2d6   |
|------------------------------------------------------------------+------------|
| safeTransferFrom(address,address,uint256,uint256,bytes)          | f242432a   |
|------------------------------------------------------------------+------------|
| setApprovalForAll(address,bool)                                  | a22cb465   |
|------------------------------------------------------------------+------------|
| supportsInterface(bytes4)                                        | 01ffc9a7   |
|------------------------------------------------------------------+------------|
| uri(uint256)                                                     | 0e89341c   |
╰------------------------------------------------------------------+------------╯
 */
