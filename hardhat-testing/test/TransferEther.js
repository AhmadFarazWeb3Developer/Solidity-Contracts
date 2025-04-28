let { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Transfer Ether ", () => {
  const startTransactionLoader = async () => {
    const [owner] = await ethers.getSigners();
    const CONTRACT = await ethers.getContractFactory("TransferEther");
    const deployedContract = await CONTRACT.deploy();
    await deployedContract.waitForDeployment();

    return { owner, deployedContract };
  };

  describe("Deployment", () => {
    it("should get actual owner", async () => {
      const { owner, deployedContract } = await loadFixture(
        startTransactionLoader
      );
      const deployerAddress = await deployedContract.signer; // get contract's own address
      console.log(deployerAddress);
      expect(deployerAddress).to.equal(owner);
    });
  });
});
