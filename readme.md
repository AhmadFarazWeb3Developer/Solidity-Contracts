
# Solidity-Contracts

A comprehensive repository featuring Solidity implementations, libraries, standards, and testing using popular tooling frameworks.

---

## Key Highlights

### ERC Token Standards

This repo includes implementations of fundamental Ethereum standards:

* **ERC-20** — Fungible tokens
* **ERC-721** — Non-fungible tokens (NFTs)
* **ERC-1155** — Multi-token standard for both fungibles and NFTs
* **ERC-165** — Interface detection
* **ERC-4337** — Account abstraction (UserOperations)
* **ERC-2612** — Permit (gasless approvals)
* **EIP-712** — Typed structured data signing

---

### Smart Contract Projects (`/hardhat-testing/contracts`)

Diverse contract examples with built-in tests:

* `TokenMarketplace.sol` — Buy & sell marketplace
* `Voting.sol` — On-chain governance
* `Twitter.sol` — Simplified social feed
* `MerkleProof.sol` — Verifying Merkle proofs
* `NftMint.sol` — Pre- & post-minting flow
* `TransferEther.sol` — Native ETH transfers
* `Wallet.sol` — Basic smart wallet
* `ToDoList.sol` — Decentralized task management

---

### Libraries (`/libraries-testing/contracts`)

Re-usable access and ownership modules:

* **AccessControl** — Role-based control (`AccessControl.sol`, `IAccessControl.sol`)
* **AccessManager** — Advanced control patterns (`AccessManaged.sol`, `AccessManager.sol`, `AuthorityUtils.sol`)
* **Ownable** — Ownership logic (`Ownable.sol`, `Ownable2Step.sol`)
* **Extensions** — Default admin rules, enumerable roles

---

### Upgradeable Contracts (`/upgradeable-contracts/src`)

Upgradeable proxies are implemented:

* **Basic Proxy** (`Implementation1.sol`, `Implementation2.sol`, `Proxy.sol`)
* **Transparent Proxy** (`ERC1967Proxy.sol`, `ERC1967Upgrade.sol`, `ProxyAdmin.sol`, `TransparentUpgradeableProxy.sol`)
* **UUPS Pattern** (`Initializable.sol`, `UUPSUpgradeable.sol`)

---

### EVM (`/EVM/src`)

* **/ABI_Encoding**
  * `DotEncode.sol`
  * `DotEncodePacked.sol`
  * `DotEncodeWithSelector.sol`
  * `DotEncodeWithSignature.sol`

* `BitsMasking.sol`  
* `BitsShifting.sol`  
* `Call.sol`  
* `CallData.sol`  
* `ConstantVar.sol`  
* `DynamicMask.sol`  
* `StorageVariables.sol`  
* `Strings.sol`  
* `TypeError.sol`

---

### Gnosis Safe (`/gnosis-safe/src`)

Smart account & multi-signature wallet implementation inspired by **Safe (formerly Gnosis Safe)**:

* Transaction execution & batching
* Threshold-based signature verification
* Guards and modules for flexible extensions

---

## Testing Frameworks

All projects include testing frameworks across tools:

* **Hardhat** — JavaScript & TypeScript testing environment
* **Foundry** — Forge + Cast for Solidity-native tests
* **Chai** and **Mocha** — BDD-style assertions and test runners

## Quick Getting Started

```bash
git clone https://github.com/AhmadFarazWeb3Developer/Solidity-Contracts.git
cd Solidity-Contracts/ERC1155  # or any sub-project
forge test                     # if using Foundry
npx hardhat test               # if using Hardhat
```

---
