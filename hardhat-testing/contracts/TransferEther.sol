// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TransferEther{
    bool pendingState=false;
   
    function setPendingState(bool _state) public {
        pendingState=_state;
    }

    function transferEther(address payable _toAddress) public payable {
        require(pendingState==true,"Trasaction is pending");
        (bool sent, bytes memory data) = _toAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ethers");
    }

    function getEthers(address _address) public view  returns (uint256) {
        return address(_address).balance;
    }
}
