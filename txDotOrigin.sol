// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/*
 tx.origin is a global variable in Ethereum smart contracts that
 represents the external account that initiated the transaction.
 it contains the address of the user account that 
 first created and sent the transaction to the network
 
 
 As we know that all the most of the functions are called via externally owned account
 but some time we the functions are called via contract , thats why som time we want that the 
 function should be only called by an externally owned account 
 
 */

contract A {
    // object of B contract
    B public bContract;

    constructor(address _bAddress) {
        bContract = B(_bAddress);
    }

    function callB() public view returns (address, address) {
        return bContract.callC();
    }
}

contract B {
    // object of C contract
    C public cContract;

    constructor(address _cAddress) {
        cContract = C(_cAddress);
    }

    function callC() public view returns (address, address) {
        return cContract.getOriginAndSender();
    }
}

contract C {
    function getOriginAndSender() public view returns (address, address) {
        return (tx.origin, msg.sender);
    }
}
