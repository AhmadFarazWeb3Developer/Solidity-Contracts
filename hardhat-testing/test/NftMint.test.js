const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { MerkleProofGenerator } = require("./utils/merkleProof");
const { parseEther } = require("ethers");
const CIDs = [
  "QmVLwvmGehsrNEvhcCnnsw5RQNseohgEkFNN1848zNzdng",
  "QmXoYpZQpWvZ5Yt9V1z5ZQpWvZ5Yt9V1z5ZQpWvZ5Yt9V1",
  "QmYwAPJzv5CZsnAzt8auVTL5zYt9V1z5ZQpWvZ5Yt9V1z5",
  "QmZbYt9V1z5ZQpWvZ5Yt9V1z5ZQpWvZ5Yt9V1z5ZQpWvZ5",
  "QmAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVv",
];
describe("NFT Miniting", () => {
  const NftMinintingDeployment = async () => {
    const signers = await ethers.getSigners();
    const allowedAddresses = [];
    let preSaleSigner = 0;
    let publicSaleSigner = 0;
    for (let i = 0; i < signers.length; i++) {
      allowedAddresses.push(await signers[i].getAddress());
      if (i === 15) {
        preSaleSigner = signers[i];
      }
      if (i === 2) {
        publicSaleSigner = signers[i];
      }
    }
    const { proof, root } = MerkleProofGenerator(
      allowedAddresses,
      await preSaleSigner.getAddress()
    );

    const Contract = await ethers.getContractFactory("MintNFT");
    const deployed_NftMint = await Contract.deploy(root, "https://pinata/api");

    return { deployed_NftMint, proof, root, preSaleSigner, publicSaleSigner };
  };

  describe("Presale Mint", () => {
    beforeEach(async () => {
      ({ deployed_NftMint, proof, root, preSaleSigner, publicSaleSigner } =
        await loadFixture(NftMinintingDeployment));
    });

    it("should pre-mint the NFTs ", async () => {
      const requiredEth = await ethers.parseEther("0.5"); // 5nfts * 0.01

      await deployed_NftMint
        .connect(preSaleSigner)
        .preSaleMint(5, proof, CIDs, {
          value: requiredEth,
        });
      expect(Number(await deployed_NftMint.balanceOf(preSaleSigner))).to.equal(
        5
      );
      expect(
        await ethers.formatEther(
          await ethers.provider.getBalance(deployed_NftMint)
        )
      ).to.equal(await ethers.formatEther(requiredEth));
    });

    it("should post-mint the NFTs", async () => {
      const requiredEth = await ethers.parseEther("0.1"); // 5nfts * 0.01 * 2

      await deployed_NftMint
        .connect(publicSaleSigner)
        .publicSaleMint(5, CIDs, { value: requiredEth });

      expect(
        await ethers.formatEther(
          await ethers.provider.getBalance(deployed_NftMint)
        )
      ).to.equal(await ethers.formatEther(requiredEth));
    });
  });
});
