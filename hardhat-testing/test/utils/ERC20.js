const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

async function deployERC20() {
  const INITIAL_SUPPLY = 1000n * 10n ** 18n;
  const CONTRACT = await ethers.getContractFactory("PKBK");
  const deployedContract = await CONTRACT.deploy(INITIAL_SUPPLY);
  await deployedContract.waitForDeployment();
  return deployedContract;
}
module.exports = { deployERC20 };
