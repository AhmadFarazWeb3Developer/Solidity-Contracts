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
import {DotEncode} from "../src/ABI_Encoding/DotEncode.sol";
import {DotEncodePacked} from "../src/ABI_Encoding/DotEncodePacked.sol";
import {DotEncodeWithSignature} from "../src/ABI_Encoding/DotEncodeWithSignature.sol";

abstract contract UtilsTest is Test {
    StorageVariables storageVars;
    ConstantIsNotOnStorage constantVar;
    TypeError typeError;

    BitsShifting bitsShifting;
    BitsMasking bitsMasking;
    BuildDynamicMask dynamicMask;

    Strings strings;

    DotEncode dotEncode;
    DotEncodePacked dotEncodePacked;

    DotEncodeWithSignature dotEncodeWithSignature;

    function setUp() public virtual {
        storageVars = new StorageVariables();
        constantVar = new ConstantIsNotOnStorage();

        typeError = new TypeError();

        bitsShifting = new BitsShifting();
        bitsMasking = new BitsMasking();

        dynamicMask = new BuildDynamicMask();

        strings = new Strings();

        dotEncode = new DotEncode();
        dotEncodePacked = new DotEncodePacked();

        dotEncodeWithSignature = new DotEncodeWithSignature();
    }
}
