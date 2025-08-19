// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ITransactionGuard} from "../../src/base/GuardManager.sol";
import {Enum} from "../../src/libraries/Enum.sol";
import {IERC165} from "../../src/interfaces/IERC165.sol";

contract SimpleGuard is ITransactionGuard {
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external override {
        // Add your guard logic here
        // For testing, you can just allow everything
    }

    function checkAfterExecution(bytes32 hash, bool success) external override {
        // Post-execution checks
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {
        return
            interfaceId == type(ITransactionGuard).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
