const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ZeroAddress } = require("ethers");

const URI_01 =
  "https://www.istockphoto.com/photo/eye-of-model-with-colorful-art-make-up-close-up-gm814423752-131755775?searchscope=image%2Cfilm";
const URI_02 =
  "https://www.istockphoto.com/photo/beauty-cosmetics-and-makeup-bright-creative-make-up-gm898886796-248040644?searchscope=image%2Cfilm";

describe("ERC721 Contract", () => {
  const ERC721ContractDeplyoment = async () => {
    const Contract = await ethers.getContractFactory("ERC721");
    const [owner, acct1, acct2, acct3] = await ethers.getSigners();
    const deployed_erc721 = await Contract.deploy("Pak Blocks", "PKBK");
    await deployed_erc721.waitForDeployment();
    return { deployed_erc721, owner, acct1, acct2, acct3 };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({ deployed_erc721, owner, acct1, acct2, acct3 } = await loadFixture(
        ERC721ContractDeplyoment
      ));
    });

    it("should set the correct contract owner", async () => {
      expect(await deployed_erc721.contractOwner()).to.equal(owner);
    });

    it("should set the correct collection name", async () => {
      expect(await deployed_erc721.name()).to.equal("Pak Blocks");
    });

    it("should set the correct collection symbol", async () => {
      expect(await deployed_erc721.symbol()).to.equal("PKBK");
    });

    it("should initialize with tokenId 0", async () => {
      expect(Number(await deployed_erc721.nextTokenIdToMint())).to.equal(0);
    });

    it("should initialize with 0 total supply", async () => {
      expect(Number(await deployed_erc721.totalSupply())).to.equal(0);
    });
  });

  describe("Minting", () => {
    beforeEach(async () => {
      ({ deployed_erc721 } = await loadFixture(ERC721ContractDeplyoment));
    });

    it("should allow contract owner to mint tokens", async () => {
      await deployed_erc721.mintTo(acct1, URI_01);
      await deployed_erc721.mintTo(acct1, URI_02);

      expect(Number(await deployed_erc721.nextTokenIdToMint())).to.equal(2);
    });

    it("should prevent non-owner from minting tokens", async () => {
      await expect(
        deployed_erc721.connect(acct1).mintTo(acct2, URI_01)
      ).to.be.revertedWith("!Auth");
    });
  });

  describe("Single Token Approval", () => {
    beforeEach(async () => {
      ({ deployed_erc721 } = await loadFixture(ERC721ContractDeplyoment));
    });

    it("should approve and transfer a single token, then clear approval", async () => {
      await deployed_erc721.mintTo(acct1, URI_01);
      await deployed_erc721.mintTo(acct1, URI_02);

      await deployed_erc721.connect(acct1).approve(acct2, 0);
      expect(await deployed_erc721.getApproved(0)).to.equal(acct2);

      await deployed_erc721.connect(acct2).transferFrom(acct1, acct3, 0);
      expect(await deployed_erc721.getApproved(0)).to.equal(ZeroAddress);
      expect(Number(await deployed_erc721.balanceOf(acct1))).to.equal(1);
      expect(Number(await deployed_erc721.balanceOf(acct3))).to.equal(1);
    });

    it("should reject transfer after approval is cleared", async () => {
      await deployed_erc721.mintTo(acct1, URI_01);
      await deployed_erc721.connect(acct1).approve(acct2, 0);
      await deployed_erc721.connect(acct2).transferFrom(acct1, acct3, 0);

      await expect(
        deployed_erc721.connect(acct2).transferFrom(acct1, acct3, 0)
      ).to.be.revertedWith("!Auth");
    });
  });

  describe("Operator (All Token) Approval", () => {
    beforeEach(async () => {
      ({ deployed_erc721 } = await loadFixture(ERC721ContractDeplyoment));
    });

    it("should approve an operator to manage all tokens", async () => {
      await deployed_erc721.mintTo(acct1, URI_01);
      await deployed_erc721.mintTo(acct1, URI_02);

      await deployed_erc721.connect(acct1).setApprovalForAll(acct2, true);
      expect(await deployed_erc721.isApprovedForAll(acct1, acct2)).to.equal(
        true
      );
    });

    it("should allow operator to safely transfer tokens without data", async () => {
      await deployed_erc721.mintTo(acct1, URI_01);
      await deployed_erc721.mintTo(acct1, URI_02);
      await deployed_erc721.connect(acct1).setApprovalForAll(acct2, true);

      await deployed_erc721
        .connect(acct2)
        ["safeTransferFrom(address,address,uint256)"](acct1, acct3, 0);
      await deployed_erc721
        .connect(acct2)
        ["safeTransferFrom(address,address,uint256)"](acct1, acct3, 1);
    });

    it("should allow operator to safely transfer tokens with data", async () => {
      await deployed_erc721.mintTo(acct1, URI_01);
      await deployed_erc721.mintTo(acct1, URI_02);
      await deployed_erc721.connect(acct1).setApprovalForAll(acct2, true);

      await deployed_erc721
        .connect(acct2)
        ["safeTransferFrom(address,address,uint256,bytes)"](
          acct1,
          acct3,
          0,
          "0x12345678"
        );
      await deployed_erc721
        .connect(acct2)
        ["safeTransferFrom(address,address,uint256,bytes)"](
          acct1,
          acct3,
          1,
          "0x12345678"
        );
    });
  });
});
