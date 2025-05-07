// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Wallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not owner");
        _;
    }

    function transferToContract() external payable {
        emit ContractFuned(msg.value);
    }

    function TransferToUserViaContract(
        address _to,
        uint _amount
    ) external payable {
        require(address(this).balance >= _amount, "Insufficient balance");
        _to.transfer(_amount);
    }

    function transferToUserDirectly(
        address payable _to,
        uint _amount
    ) external payable {
        require(owner.balance >= msg.value, "Insufficient balance");
        payable(_to).transfer(_amount);
    }

    function withdarwFromContract(uint _amount) payable {
        owner.transfer(_amount);
    }

    function reciveFromUser() external payable {
        require(msg.value > 0, "Wei amount must be greater than 0");
        payable(owner).transfer(msg.value);
    }

    // receiv function is at the top prority if its exists its called

    receive() external payable {}

    // if receive function exists its called otherwise the transaction is reverted
    fallback() external {} // it executes when the contract function is called  which does'nt exists here

    // this issue come when user interact with low level calls , there is chance of panic

    event ContractFuned(uint indexed Eth);
}
