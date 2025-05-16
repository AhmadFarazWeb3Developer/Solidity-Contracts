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
    it("Should check the contract name", async () => {
      console.log(await deployed_erc721.name());
    });
  });
});
