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
      const time = 3600;
      const Ethers = await ethers.parseEther("10");
      await deployed_contract.transferToContract(time, { value: Ethers });
      expect(
        await ethers.formatEther(
          await ethers.provider.getBalance(deployed_contract.target)
        )
      ).to.equal("10.0");
    });
    it("Should transfer ETH via contract", async () => {
      const time = 3600;
      const Ethers = await ethers.parseEther("10");
      // first send eth to contract
      await deployed_contract.transferToContract(time, { value: Ethers });
      await deployed_contract.transferToUserViaContract(acct1, Ethers);
    });
  });
  describe("Owner", () => {
    beforeEach(async () => {
      ({ deployed_contract } = await loadFixture(WalletDeployment));
    });

    it("Should change the owner", async () => {
      await deployed_contract.connect(owner).changeOwner(acct1);
      console.log(await deployed_contract.suspiciousUser(acct1));
      await deployed_contract.connect(acct1).changeOwner(acct2);
      console.log(await deployed_contract.suspiciousUser(acct2));
      await deployed_contract.connect(acct2).changeOwner(acct3);
      console.log(await deployed_contract.suspiciousUser(acct3));
      await deployed_contract.connect(acct3).changeOwner(acct4);
      console.log(await deployed_contract.suspiciousUser(acct4));
      await deployed_contract.connect(acct4).changeOwner(acct5);
      console.log(await deployed_contract.suspiciousUserCouter());
    });
  });
});
