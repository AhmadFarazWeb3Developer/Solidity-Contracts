const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

const { deployERC20 } = require("./utils/ERC20");

describe("Token Marketplace", () => {
  const deployTokenMarketplace = async () => {
    const { pkbk_deployedContract, token_marketplace_deplyedContract } =
      await deployERC20();

    const [acct1, acct2, acct3, acct4] = await ethers.getSigners();

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

    it("Should calculate the token price", async () => {
      const tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );
      expect(await ethers.formatEther(tokenPrice)).to.equal("0.2");
    });

    it("User should be able to buy tokens", async () => {
      // Static call returns only the requested data, not the full transaction object
      let tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );

      // First buyer
      await token_marketplace_deplyedContract
        .connect(acct2)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      expect(
        parseFloat(
          await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct1))
        )
      ).to.be.above(parseFloat(await ethers.formatUnits(tokenPrice)));

      // Second account token price calculation
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
          await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct2))
        )
      ).to.be.above(parseFloat(await ethers.formatUnits(tokenPrice)));

      // Calculate token price again for the third account
      tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );
      await token_marketplace_deplyedContract
        .connect(acct4)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      expect(
        parseFloat(
          await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct3))
        )
      ).to.be.above(parseFloat(await ethers.formatUnits(tokenPrice)));
    });
  });

  describe("Sell Tokens", () => {
    const tokens = 10n * 10n ** 18n;

    beforeEach(async () => {
      ({ token_marketplace_deplyedContract, pkbk_deployedContract } =
        await loadFixture(deployTokenMarketplace));
    });

    it("Should approve the seller to sell tokens", async () => {
      // Simulate the approval to confirm it will succeed
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

      // First buyer
      await token_marketplace_deplyedContract
        .connect(acct2)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      // Now the contract has received ethers
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

      // Now the token price is updated, so fund the contract with extra ethers to pay back the seller's profit
      await acct1.sendTransaction({
        to: token_marketplace_deplyedContract.target,
        value: ethers.parseEther("10"), // Give it 10 ETH
      });

      // Now sell the tokens
      await token_marketplace_deplyedContract
        .connect(acct2)
        .sellPKBKToken(tokens);

      // console.log(await ethers.formatEther(await ethers.provider.getBalance(acct2)));
    });
  });

  describe("Withdraw Tokens", () => {
    const tokens = 50n * 10n ** 18n;

    beforeEach(async () => {
      ({ token_marketplace_deplyedContract, pkbk_deployedContract } =
        await loadFixture(deployTokenMarketplace));
    });
    it("Should send tokens to Owner", async () => {
      await token_marketplace_deplyedContract
        .connect(acct1)
        .withDrawTokens(tokens);

      expect(
        await ethers.formatEther(await pkbk_deployedContract.balanceOf(acct1))
      ).to.equal("950.0");
      expect(
        await ethers.formatEther(
          await pkbk_deployedContract.balanceOf(
            token_marketplace_deplyedContract.target
          )
        )
      ).to.equal("50.0");
    });
  });

  describe("Withdraw ETH", () => {
    beforeEach(async () => {
      ({ token_marketplace_deplyedContract, pkbk_deployedContract } =
        await loadFixture(deployTokenMarketplace));
    });

    it("Should withdraw ETH of contract", async () => {
      const tokens = 100n * 10n ** 18n; // 2.0 ethers price

      // First buy some tokens
      let tokenPrice =
        await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
          tokens
        );

      // First buyer
      await token_marketplace_deplyedContract
        .connect(acct2)
        .buyPKBKToken(tokens, {
          value: tokenPrice,
        });

      const OwnerBalance = parseFloat(
        await ethers.formatEther(await ethers.provider.getBalance(acct1))
      );

      expect(
        await ethers.formatEther(
          await ethers.provider.getBalance(
            token_marketplace_deplyedContract.target
          )
        )
      ).to.equal("2.0");

      // withdraw tokens
      await token_marketplace_deplyedContract.withDrawEthers(2n * 10n ** 18n);
      expect(
        parseFloat(
          await ethers.formatEther(await ethers.provider.getBalance(acct1))
        )
      ).to.above(OwnerBalance);
    });
  });
});
