const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers, BigNumber } = require("hardhat");
const { expect } = require("chai");

const { deployERC20 } = require("./utils/ERC20");

describe("Token Marketplace", () => {
  const deployTokenMarketplace = async () => {
    const { pkbk_deployedContract, token_marketplace_deplyedContract } =
      await deployERC20();

    const [acct1, acct2, acct3, acct4] = await ethers.getSigners();

    // console.log(
    //   await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct1))
    // );
    return {
      token_marketplace_deplyedContract,
      pkbk_deployedContract,
      acct1,
      acct2,
      acct3,
      acct4,
    };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({
        token_marketplace_deplyedContract,
        pkbk_deployedContract,
        acct1,
        acct2,
        acct3,
        acct4,
      } = await loadFixture(deployTokenMarketplace));
    });

    it("should have 100 tokens", async () => {
      expect(
        await ethers.formatEther(
          await pkbk_deployedContract.balanceOf(
            token_marketplace_deplyedContract.target
          )
        )
      ).to.equal("100.0");
    });
  });

  describe("Buy Tokens", () => {
    const tokens = 10n * 10n ** 18n;

    beforeEach(async () => {
      ({ token_marketplace_deplyedContract, pkbk_deployedContract } =
        await loadFixture(deployTokenMarketplace));
    });

    it("Should calculate token price", async () => {
      const tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );
      expect(await ethers.formatEther(tokenPrice)).to.equal("0.2");
    });

    it("User should able to buy tokens ", async () => {
      // static call just return the  requested data not the whole object
      let tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );

      // first buyer
      await token_marketplace_deplyedContract
        .connect(acct1)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      expect(
        parseFloat(
          await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct1))
        )
      ).to.be.above(parseFloat(await ethers.formatUnits(tokenPrice))); // formatUnits = bigNumber => string

      // second account and token price calculation
      tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );
      await token_marketplace_deplyedContract
        .connect(acct2)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      expect(
        parseFloat(
          await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct2))
        )
      ).to.be.above(parseFloat(await ethers.formatUnits(tokenPrice))); // formatUnits = bigNumber => string

      //  calculate token price again for third account
      tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );
      await token_marketplace_deplyedContract
        .connect(acct3)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      expect(
        parseFloat(
          await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct3))
        )
      ).to.be.above(parseFloat(await ethers.formatUnits(tokenPrice))); // formatUnits = bigNumber => string
    });
  });

  describe("Sell Tokens", () => {
    const tokens = 10n * 10n ** 18n;
    beforeEach(async () => {
      ({ token_marketplace_deplyedContract, pkbk_deployedContract, acct1 } =
        await loadFixture(deployTokenMarketplace));
    });
    it("Should approve seller of tokens", async () => {
      // Simulate to confirm the approve will succeed
      expect(
        await pkbk_deployedContract
          .connect(acct2)
          .approve.staticCall(acct1, tokens)
      ).to.equal(true);

      expect(
        await pkbk_deployedContract
          .connect(acct3)
          .approve.staticCall(token_marketplace_deplyedContract.target, tokens)
      ).to.equal(true);
    });

    it("Should sell the tokens", async () => {
      const tokens = 10n * 10n ** 18n;

      // First buy some tokens
      let tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );

      // first buyer
      await token_marketplace_deplyedContract
        .connect(acct2)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      // Now contract get Ethers
      expect(
        await ethers.formatEther(
          await ethers.provider.getBalance(
            token_marketplace_deplyedContract.target
          )
        )
      ).to.equal("0.2"); // 10 tokens * 0.02 ETH = 0.2 ETH

      // Actually send the transaction for approval
      await pkbk_deployedContract
        .connect(acct2)
        .approve(token_marketplace_deplyedContract.target, tokens);

      // Now tokens price is updated so funding my contract with extra eths to pay back profit to seller

      await acct1.sendTransaction({
        to: token_marketplace_deplyedContract.target,
        value: ethers.parseEther("10"), // Give it 10 ETH
      });

      await token_marketplace_deplyedContract
        .connect(acct2)
        .sellPKBKToken(tokens);
      console.log(
        await ethers.formatEther(await ethers.provider.getBalance(acct2))
      );
    });
  });
});
