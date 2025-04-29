const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ERC20", () => {
  const deployedERC20 = async () => {
    // const INITIAL_SUPPLY = ethers.parseUnits("1000", 18); // 1000 tokens with 18 decimals
    const INITIAL_SUPPLY = 1000n * 10n ** 18n; //1000 tokens supply with 10^18 decimals
    const [owner] = await ethers.getSigners();
    const CONTRACT = await ethers.getContractFactory("PKBK");
    const deployedContract = await CONTRACT.deploy(INITIAL_SUPPLY);
    await deployedContract.waitForDeployment();
    return { owner, deployedContract };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({ owner, deployedContract } = await loadFixture(deployedERC20));
    });

    it("Should set the inial supply", async () => {
      expect(
        await ethers.formatEther(await deployedContract.totalSupply())
      ).to.equal("1000.0");
    });
    it("Should set Token Name", async () => {
      expect(await deployedContract.name()).to.equal("Pak Block");
    });
    it("Should set Token  Symbol", async () => {
      expect(await deployedContract.symbol()).to.equal("pkbk");
    });
    it("Should set 18 decimals", async () => {
      expect(await deployedContract.decimals()).to.equal(18);
    });
  });
});
