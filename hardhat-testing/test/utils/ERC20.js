const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

async function deployERC20() {
  const INITIAL_SUPPLY = 1000n * 10n ** 18n;
  const PKBK_CONTRACT = await ethers.getContractFactory("PKBK");
  const pkbk_deployedContract = await PKBK_CONTRACT.deploy(INITIAL_SUPPLY);
  await pkbk_deployedContract.waitForDeployment();

  const TOKEN_MARKETPLACE_CONTRACT = await ethers.getContractFactory(
    "TokenMarketPlace"
  );

  const token_marketplace_deplyedContract =
    await TOKEN_MARKETPLACE_CONTRACT.deploy(pkbk_deployedContract.target);
  await token_marketplace_deplyedContract.waitForDeployment();

  // send 100 pkbk tokens to the token marketplace
  const SEND_TOKENS = 100n * 10n ** 18n;
  await pkbk_deployedContract.transfer(
    token_marketplace_deplyedContract.target,
    SEND_TOKENS
  );

  // console.log(
  //   await ethers.formatEther(
  //     await pkbk_deployedContract.balanceOf(
  //       token_marketplace_deplyedContract.target
  //     )
  //   )
  // );
  return { pkbk_deployedContract, token_marketplace_deplyedContract };
}
module.exports = { deployERC20 };
