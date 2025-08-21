// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StorageVariables} from "../src/StorageVariables.sol";

import {ConstantIsNotOnStorage} from "../src/ConstantVar.sol";

abstract contract UtilsTest is Test {
    StorageVariables storageVars;
    ConstantIsNotOnStorage constantVar;

    function setUp() public virtual {
        storageVars = new StorageVariables();
        constantVar = new ConstantIsNotOnStorage();
    }
}
