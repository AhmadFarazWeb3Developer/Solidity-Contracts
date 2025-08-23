// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {Test, console, console2} from "forge-std/Test.sol";
import {UtilsTest} from "./Utils.t.sol";

contract DotEncodeTest is UtilsTest {
    function setUp() public override {
        super.setUp();
    }

    // Static Types Encoding
    function test_AddressEncode() public view {
        dotEncode.AddressEncode(); // 0x000000000000000000000000d6b0794b7aea7190f1831a40393e599cc0864eb3
    }

    function test_BytesEncode() public view {
        dotEncode.BytesEncode(); // 0x00000000000000000000000000000000000000000000000000000000abcdef12
    }

    function test_UintsEncode() public view {
        dotEncode.UintsEncode(); // 0x0000000000000000000000000000000000291bf5139ecbf97aeba956631f8503
    }

    function test_BooleanEncode() public view {
        dotEncode.BooleanEncode(); // 0x0000000000000000000000000000000000000000000000000000000000000001
    }

    function test_StaticMix() public view {
        bytes memory data = dotEncode.StaticMix(); // 0x000000000000000000000000d6b0794b7aea7190f1831a40393e599cc0864eb3000000000000000000000000000000000000000000000000000000000001d9e0abcdef1200000000000000000000000000000000000000000000000000000000

        (address ADDRESS, uint256 VAR, bytes4 BYT) = abi.decode(
            data,
            (address, uint256, bytes4)
        );

        console.log(ADDRESS);
        console.log(VAR);
        console.logBytes4(BYT);
    }

    // Dynamic Types Encoding
    function test_StringEncode() public view {
        dotEncode.StringEncode();
        /*
            0x0000000000000000000000000000000000000000000000000000000000000020 -> offset
            0000000000000000000000000000000000000000000000000000000000000003 -> length
            59554c0000000000000000000000000000000000000000000000000000000000 -> content
        */
    }

    //////////////////////////////////////////////////////////////////////////////////////////////

    //----------------------- DYNAMIC TYPES ENCODING --------------------------------------------

    //////////////////////////////////////////////////////////////////////////////////////////////

    function test_DynamicBytesEncode() public view {
        // READ : dotEncode.DynamicBytesEncode(bytes(0x1212fdaffcde5));
        // Cannot do this. The issue is that 0x1212fdaffcde5 is a number literal, and you can't directly cast numbers to bytes memory.

        // Casting to Bytes

        // 1 method:
        dotEncode.DynamicBytesEncode(hex"01212fdaffcde5"); // add 0 to start for hex understanding

        /*
            DynamicBytesEncode(0x01212fdaffcde5) 
                [Return] 0x0000000000000000000000000000000000000000000000000000000000000020
                         0000000000000000000000000000000000000000000000000000000000000007
                         01212fdaffcde500000000000000000000000000000000000000000000000000
        */

        // 2 method:
        dotEncode.DynamicBytesEncode(
            abi.encodePacked(uint256(0x1212fdaffcde5))
        );

        /*
            DynamicBytesEncode(0x0000000000000000000000000000000000000000000000000001212fdaffcde5) 
                [Return] 0x0000000000000000000000000000000000000000000000000000000000000020
                         0000000000000000000000000000000000000000000000000000000000000020
                         0000000000000000000000000000000000000000000000000001212fdaffcde5
        */

        // 3 method:
        dotEncode.DynamicBytesEncode("\x12\x12\xfd\xaf\xfc\xde\x05");

        /*
            DynamicBytesEncode(0x1212fdaffcde05) [staticcall]
                [Return] 0x0000000000000000000000000000000000000000000000000000000000000020
                         0000000000000000000000000000000000000000000000000000000000000007
                         1212fdaffcde0500000000000000000000000000000000000000000000000000
        */
    }

    function test_UintsArrayEncode() public view {
        bytes memory hashedData = dotEncode.UintsArrayEncode();
        /*
        0x0000000000000000000000000000000000000000000000000000000000000020 -> offset
          0000000000000000000000000000000000000000000000000000000000000001 -> length
          000000000000000000000000000000000000000000000000000000000000008f -> first element
          000000000000000000000000000000000000000000000000000000000000064  -> second element            
         */

        // DECODING
        uint256[] memory uintArray = abi.decode(hashedData, (uint256[]));
        for (uint256 i = 0; i < uintArray.length; i++) {
            console.log(uintArray[i]);
        }
    }
    function test_BytesArrayEncode() public view {
        bytes memory hashedData = dotEncode.BytesArrayEncode();
        /*
         0x0000000000000000000000000000000000000000000000000000000000000020 -> offset
           0000000000000000000000000000000000000000000000000000000000000002 -> length
           123456e100000000000000000000000000000000000000000000000000000000 -> first bytes element
           a12e3f8f00000000000000000000000000000000000000000000000000000000 -> seconf bytes element      
         */

        // DECODING
        bytes4[] memory bytesArray = abi.decode(hashedData, (bytes4[]));
        for (uint256 i = 0; i < bytesArray.length; i++) {
            console.logBytes4(bytesArray[i]);
        }
    }

    function test_StringArrayEncode() public view {
        bytes memory hashedData = dotEncode.StringArrayEncode();
        /*

        WHEN :
        stringArray = ["Hello are you enjoying the YUL", "Yes solidity made it awesome"]

        0x0000000000000000000000000000000000000000000000000000000000000020 -> offset of array 
         0000000000000000000000000000000000000000000000000000000000000002 -> lenght of array
         0000000000000000000000000000000000000000000000000000000000000040 -> first index offset
         0000000000000000000000000000000000000000000000000000000000000080 -> second index offset
         000000000000000000000000000000000000000000000000000000000000001d -> length of first element
         48656c6c6f20617220796f7520656e6a6f79696e67207468652059554c000000 -> first index content 
         000000000000000000000000000000000000000000000000000000000000001c -> length of second element 
         59657320736f6c6964697479206d61646520697420617765736f6d6500000000 -> second index content



        WHEN : 
        stringArray = ["Hello are you enjoying the YUL Programming language", "Yes solidity made it awesome"]

        0x0000000000000000000000000000000000000000000000000000000000000020 -> offset of array 
         0000000000000000000000000000000000000000000000000000000000000002 -> length of array
         0000000000000000000000000000000000000000000000000000000000000040 -> first index offset
         00000000000000000000000000000000000000000000000000000000000000a0 -> second index offset
         0000000000000000000000000000000000000000000000000000000000000033 -> lenght of first index
         48656c6c6f2061726520796f7520656e6a6f79696e67207468652059554c2050 -> first index content
         726f6772616d6d696e67206c616e677561676500000000000000000000000000 
         000000000000000000000000000000000000000000000000000000000000001c -> length of second index
         59657320736f6c6964697479206d61646520697420617765736f6d6500000000 -> second index content
        */
        // DECODING
        string[] memory stringArray = abi.decode(hashedData, (string[]));
        for (uint256 i = 0; i < stringArray.length; i++) {
            console.log(stringArray[i]);
        }
    }

    function test_StructEncode() public view {
        dotEncode.StructEncode();

        /*
        struct myStruct {
            string data;
            uint256 id;
        }
          myStruct memory s = myStruct({id: 1122, data: "Hello Yul!"});

          0x0000000000000000000000000000000000000000000000000000000000000020 -> offset
            0000000000000000000000000000000000000000000000000000000000000462 -> 1122
            0000000000000000000000000000000000000000000000000000000000000040 -> string offset
            000000000000000000000000000000000000000000000000000000000000000a -> length of string 
            48656c6c6f2059756c2100000000000000000000000000000000000000000000 -> content
        




        struct myStruct {
            string data;
            uint256 id;
        }

        0x0000000000000000000000000000000000000000000000000000000000000020 -> offset
          0000000000000000000000000000000000000000000000000000000000000040 -> string offset 
          0000000000000000000000000000000000000000000000000000000000000462 -> 1122
          000000000000000000000000000000000000000000000000000000000000000a -> length of string
          48656c6c6f2059756c2100000000000000000000000000000000000000000000 -> content


        Solidity does not care about the order of types ,
        if the types if dyamic or refrecen type it hold the pointer to it

         */
    }
}

/*

Some Solidity types are not supported by the ABI, but they are able to be represented by the static types below.
  ┌───────────────────────────┬───────────────────────────┐
  │        Solidity Type      │          ABI Type         │
  ├───────────────────────────┼───────────────────────────┤
  │ address payable           │ address                   │
  │ contract                  │ address                   │
  │ enum                      │ uint8                     │
  │ user defined value types  │ underlying value type     │
  │ struct                    │ tuple                     │
  └───────────────────────────┴───────────────────────────┘

  It means if we try to abi.encode(payable(anyAddress)), so payable does not effect the encoded bytes 

*/
