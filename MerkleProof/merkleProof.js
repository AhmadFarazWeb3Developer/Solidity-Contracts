const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

// Step 2: Define the allowlist and create a Merkle Tree
const allowlistAddresses = [
  "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
  "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
  "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
  "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
];

const leafNodes = allowlistAddresses.map((addr) => keccak256(addr));
// console.log(leafNodes);
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
const root = merkleTree.getHexRoot();
// console.log(root);
// Step 5: Generate the Merkle proof for a specific address
const addressToVerify = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2";
const leaf = keccak256(addressToVerify);
const proof = merkleTree.getHexProof(leaf);
// Convert to JSON string and remove all whitespace
const proofString = JSON.stringify(proof).replace(/\s+/g, "");

console.log("Proof String:", proofString);
console.log("Root:", root);
