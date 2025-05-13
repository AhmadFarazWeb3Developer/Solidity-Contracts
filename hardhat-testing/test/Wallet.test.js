const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");

const { expect } = require("chai");
describe("Wallet", () => {
  const WalletDeployment = async () => {
    const CONTRACT = await ethers.getContractFactory("Wallet");
    const [owner, acct1, acct2, acct3, acct4, acct5] =
      await ethers.getSigners();
    const deployed_contract = await CONTRACT.deploy(owner);
    await deployed_contract.waitForDeployment();

    return { deployed_contract, owner, acct1, acct2, acct3, acct4, acct5 };
  };
  describe("Transaction", () => {
    beforeEach(async () => {
      ({ deployed_contract, owner, acct1, acct2, acct3, acct4, acct5 } =
        await loadFixture(WalletDeployment));
    });
    it("Shoud transfer ETH to contract", async () => {
      const Ethers = await ethers.parseEther("10");
      await deployed_contract.transferToContract({ value: Ethers });
      expect(
        await ethers.formatEther(
          await ethers.provider.getBalance(deployed_contract.target)
        )
      ).to.equal("10.0");
    });
    it("Should transfer ETH via contract", async () => {
      const Ethers = await ethers.parseEther("10");
      // first send eth to contract
      await deployed_contract.transferToContract({ value: Ethers });
      await deployed_contract.transferToUserViaContract(acct1, Ethers);
    });
  });
  describe("Owner", () => {
    beforeEach(async () => {
      ({ deployed_contract } = await loadFixture(WalletDeployment));
    });

    it("Should change the owner", async () => {
      let accouts = [owner, acct1, acct2, acct3, acct4];

      // increase couter to five then try to add new owner
      for (let i = 0; i < accouts.length - 1; i++) {
        await deployed_contract.connect(accouts[i]).changeOwner(accouts[i + 1]);
      }

      expect(await deployed_contract.suspiciousUserCouter()).to.equal(5n);
      // should not add the more then 4 owners
      await expect(
        deployed_contract.connect(accouts[4]).changeOwner(acct5)
      ).to.be.revertedWith("Activity found suspicious, Try later");
    });
    it("Should declare the emergency", async () => {
      await deployed_contract.toggleStop();
      await expect(
        deployed_contract.connect(owner).changeOwner(acct1)
      ).to.be.revertedWith("Emergency declared");
    });
  });
});
