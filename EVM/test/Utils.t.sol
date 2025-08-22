// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StorageVariables} from "../src/StorageVariables.sol";
import {ConstantIsNotOnStorage} from "../src/ConstantVar.sol";
import {TypeError} from "../src/TypeError.sol";
import {BitsShifting} from "../src/BitsShifting.sol";
import {BitsMasking} from "../src/BitsMasking.sol";

import {BuildDynamicMask} from "../src/DynamicMask.sol";
import {Strings} from "../src/Strings.sol";

abstract contract UtilsTest is Test {
    StorageVariables storageVars;
    ConstantIsNotOnStorage constantVar;
    TypeError typeError;

    BitsShifting bitsShifting;
    BitsMasking bitsMasking;
    BuildDynamicMask dynamicMask;

    Strings strings;

    function setUp() public virtual {
        storageVars = new StorageVariables();
        constantVar = new ConstantIsNotOnStorage();

        typeError = new TypeError();

        bitsShifting = new BitsShifting();
        bitsMasking = new BitsMasking();

        dynamicMask = new BuildDynamicMask();

        strings = new Strings();
    }
}
