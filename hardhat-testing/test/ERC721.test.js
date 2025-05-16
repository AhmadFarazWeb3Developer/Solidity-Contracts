const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("ERC721 Contract", () => {
  const ERC721ContractDeplyoment = async () => {
    const Contract = await ethers.getContractFactory("ERC721");
    const [owner] = await ethers.getSigners();
    const deployed_erc721 = await Contract.deploy("Pak Blocks", "PKBK");
    await deployed_erc721.waitForDeployment();
    return { deployed_erc721, owner };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({ deployed_erc721, owner } = await loadFixture(
        ERC721ContractDeplyoment
      ));
    });
    it("Should check the contract owner", async () => {
      console.log(await deployed_erc721.contractOwner());
    });
    it("Should check the collection name", async () => {
      console.log(await deployed_erc721.name());
    });
    it("Should check the collection symbol ", async () => {
      console.log(await deployed_erc721.symbol());
    });
    it("Should check the next token Id ", async () => {
      console.log(await deployed_erc721.nextTokenIdToMint());
    });
    it("Should check the total supply ", async () => {
      console.log(await deployed_erc721.totalSupply());
    });
  });
});
