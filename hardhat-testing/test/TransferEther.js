let { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Transfer Ether ", () => {
  const startTransactionLoader = async () => {
    const [owner] = await ethers.getSigners();
    const CONTRACT = await ethers.getContractFactory("TransferEther");
    console.log(CONTRACT);

    return { owner };
  };

  describe("Deployment", () => {
    it("Owner check", async () => {
      const { owner } = await loadFixture(startTransactionLoader);
      console.log(await owner.address);
    });
  });
});
