let { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Transfer Ether Test", () => {
  const startTransactionLoader = async () => {
    const ETH = await ethers.parseEther("100");
    const [owner] = await ethers.getSigners();

    const CONTRACT = await ethers.getContractFactory("TransferEther");
    const deployedContract = await CONTRACT.deploy({
      value: ETH,
    });
    await deployedContract.waitForDeployment();

    return { owner, deployedContract };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({ owner, deployedContract } = await loadFixture(startTransactionLoader));
    });
    it("Should get actual owner", async () => {
      const deployerAddress = await deployedContract.runner.address; // deployer address
      expect(deployerAddress).to.equal(owner);
    });

    it("Should get false pending state", async () => {
      expect(await deployedContract.pendingState()).to.be.false;
    });
  });

  describe("Transfer ETH", () => {
    beforeEach(async () => {
      ({ owner, deployedContract } = await loadFixture(startTransactionLoader));
    });

    it("Should get ETH of owner", async () => {
      expect(await ethers.formatEther(await deployedContract.getEthers(owner)));
    });
    describe("Pending State Setup", () => {
      beforeEach(async () => {
        // Always set pendingState = true before tests inside this sub-describe
        await deployedContract.setPendingState(true);
      });

      it("Should confirm pending state is true", async () => {
        expect(await deployedContract.pendingState()).to.be.true;
      });

      it("Should transfer ETH to owner", async () => {
        const ETH = await ethers.parseEther("100");

        await deployedContract.transferEther(owner.address, ETH);

        const contractBalance = await ethers.provider.getBalance(
          deployedContract.target
        );

        expect(contractBalance).to.equal(0n);
      });
    });
  });
});
