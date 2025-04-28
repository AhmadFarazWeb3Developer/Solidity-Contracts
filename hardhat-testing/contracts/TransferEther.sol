// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TransferEther {
    bool public pendingState = false;

    constructor() payable {}

    function setPendingState(bool _state) public {
        pendingState = _state;
    }

    function transferEther(address payable _toAddress, uint256 _amount) public {
        require(pendingState == true, "Transaction is pending");
        require(address(this).balance >= _amount, "Not enough contract balance");
        
        (bool sent, ) = _toAddress.call{value: _amount}("");
        require(sent, "Failed to send Ethers");
    }

    function getEthers(address _address) public view returns (uint256) {
        return _address.balance;
    }
}
