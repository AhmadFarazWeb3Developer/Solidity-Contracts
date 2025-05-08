// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Wallet {
    struct Transaction {
        address from;
        address to;
        uint timestamp;
        uint amount;
    }

    Transaction[] public transactionHistory;
    mapping(address => uint) public suspiciousUser;

    uint public suspiciousUserCouter = 1;
    address public owner;
    bool public stop;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You don't have access");
        _;
    }

    modifier SuspiciousUser(address _sender) {
        require(
            suspiciousUser[_sender] < 5,
            "Activity found suspicious, Try later"
        );
        _;
    }

    modifier isEmergencyDeclared() {
        require(stop == false, "Emergency declared");
        _;
    }

    function toggleStop() external onlyOwner {
        stop = !stop;
    }

    function changeOwner(
        address newOwner
    ) public onlyOwner SuspiciousUser(newOwner) isEmergencyDeclared {
        owner = newOwner;
        suspiciousUser[owner] = suspiciousUserCouter++;
    }

    function transferToContract(
        uint _startTime
    ) external payable SuspiciousUser(msg.sender) {
        require(block.timestamp > _startTime, "send after start time");
        transactionHistory.push(
            Transaction(msg.sender, address(this), block.timestamp, msg.value)
        );
    }

    function transferToUserViaContract(
        address payable _to,
        uint _weiAmount
    ) external onlyOwner {
        require(address(this).balance >= _weiAmount, "Insufficient Balance");
        require(_to != address(0), "Adress format incorrect");
        _to.transfer(_weiAmount);
        transactionHistory.push(
            Transaction(msg.sender, _to, block.timestamp, _weiAmount)
        );
        emit Transfer(_to, _weiAmount);
    }

    event Transfer(address receiver, uint amount);
    event Receive(address sender, uint amonut);
    event ReceiveUser(address sender, address receiver, uint amount);
}
