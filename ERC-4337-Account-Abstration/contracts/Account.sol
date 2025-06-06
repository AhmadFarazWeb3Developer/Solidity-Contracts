// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@account-abstraction/contracts/interfaces/IAccount.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@account-abstraction/contracts/interfaces/UserOperation.sol";


// Account contract is the actual smart wallet which can have logics
// like transfer tokens etc
contract Account is IAccount {
    uint256 public count;
    address public owner;
    IEntryPoint public immutable entryPoint;

    constructor(address _owner, IEntryPoint _entryPoint) {
        owner = _owner;
        entryPoint = _entryPoint;
    }

    /// @notice Called by EntryPoint to validate the user operation
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 /* missingAccountFunds */
    ) external view override returns (uint256 validationData) {
        require(msg.sender == address(entryPoint), "Only EntryPoint can call");

        bytes32 ethSignedHash = ECDSA.toEthSignedMessageHash(userOpHash);

        address recovered = ECDSA.recover(ethSignedHash, userOp.signature);

        // validation
        if (recovered != owner) {
            return 1; // invalid
        }

        return 0; // valid
    }

    /// @notice Only EntryPoint can call actual execution
    // any function can be implemented like transfer etc
    function execute() external {
        require(msg.sender == address(entryPoint), "Only EntryPoint can call");
        count++;
    }
}


// creates the new smart account which is Account
contract AccountFactory {
    function createAccount(
        address owner,
        IEntryPoint entryPoint
    ) external returns (address) {
        Account account = new Account(owner, entryPoint);
        return address(account);
    }
}
