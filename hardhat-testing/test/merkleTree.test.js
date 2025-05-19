const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { MerkleProofGenerator } = require("./utils/merkleProof");

describe("Merkle Proof ", () => {
  const merkleProofDeployment = async () => {
    const signers = await ethers.getSigners();
    const allowedAddresses = [];
    let targetSigner = 0;
    for (let i = 0; i < signers.length; i++) {
      allowedAddresses.push(await signers[i].getAddress());
      if (i === 15) {
        targetSigner = signers[i];
      }
    }

    const { proof, root } = MerkleProofGenerator(
      allowedAddresses,
      await targetSigner.getAddress()
    );
    const Contract = await ethers.getContractFactory("MerkleTree");
    const deployed_merkleProof = await Contract.deploy(root);
    await deployed_merkleProof.waitForDeployment();

    return { deployed_merkleProof, root, proof, targetSigner };
  };

  describe("Mint", () => {
    beforeEach(async () => {
      ({ deployed_merkleProof, root, proof, targetSigner } = await loadFixture(
        merkleProofDeployment
      ));
    });

    it("should set the root", async () => {
      expect(await deployed_merkleProof.root()).to.equal(root);
    });

    it("should verify the proof", async () => {
      expect(
        await deployed_merkleProof.connect(targetSigner).safeMint(proof)
      ).to.equal(true);
    });
  });
});
