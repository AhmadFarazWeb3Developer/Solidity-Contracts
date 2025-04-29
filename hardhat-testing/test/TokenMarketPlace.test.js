const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

const { deployERC20 } = require("./utils/ERC20");

describe("Token Marketplace", () => {
  const deployTokenMarketplace = async () => {
    const _pkbkToken = await deployERC20();
    const _pkbkTokenAddres = _pkbkToken.target;
    console.log(_pkbkTokenAddres);
    const CONTRACT = await ethers.getContractFactory("TokenMarketPlace");
    const deplyedContract = await CONTRACT.deploy(_pkbkTokenAddres);
    await deplyedContract.waitForDeployment();
    return { deplyedContract };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({ deplyedContract } = await loadFixture(deployTokenMarketplace));
    });

    it("should set the token address", async () => {
      console.log(deplyedContract.target);
    });
  });
});
