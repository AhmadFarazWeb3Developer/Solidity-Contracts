const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const MerkleProofGenerator = (allowedListAddresses, targetAddress) => {
  // encodeing all address to generated 64-character hex
  // console.log(allowedListAddresses);
  const leafNodes = allowedListAddresses.map(
    (addr) => "0x" + keccak256(addr).toString("hex")
  );

  // console.log(leafNodes);

  // merkle tree creation
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  // console.log(merkleTree.toString("hex"));

  // root node generation
  const root = merkleTree.getHexRoot();
  // console.log(root);
  // Step 5: Generate the Merkle proof for a specific address

  const leaf = keccak256(targetAddress);
  // console.log(leaf);

  const proof = merkleTree.getHexProof(leaf);
  // Convert to JSON string and remove all whitespace
  const proofString = JSON.stringify(proof).replace(/\s+/g, "");

  // console.log("Proof String:", proofString);
  // console.log("Root:", root);

  return { proof, root };
};
module.exports = { MerkleProofGenerator };
/*  
                          Root
                           |
         ----------------------------------------
         |                                       |
         0x9d9977...bb520d65                 0x4726e4...9f19b3c
         |                                       |
         |                                       |
   0x5931b4...8dd229  <-- A              0x04a10b...fcb54 <-- C
   0x999bf5...6cdb    <-- B              0xdfbe3e...9486  <-- D
  
 
   If verifying address "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2" its hash is 
   0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb

   it means verifying the "B" with result the proof with two hashes 
   1) Hash of A = H(A), means sibling
   2) Collective hash of C+ D= H(C+D), means Hash of right subtree or sibling hash at level 1 
      or uncle node hash 
   */
