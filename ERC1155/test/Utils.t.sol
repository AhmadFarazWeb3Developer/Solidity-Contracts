// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {Game} from "../src/Game.sol";

abstract contract Utils is Test {
    Game game;
    address minter = makeAddr("minter");
    function setUp() public virtual {
        vm.startPrank(minter);
        game = new Game();
        vm.stopPrank();
    }
}
