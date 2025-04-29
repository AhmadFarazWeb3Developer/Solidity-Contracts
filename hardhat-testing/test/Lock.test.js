const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", () => {
  const deployOneHourLockFixture = async () => {
    const ONE_HOUR_IN_SEC = 3600;
    const ONE_ETH = ethers.parseEther("1");
    // one Gwei == 10^9 wei and  1 Eth = 10^18 wei

    const lockedAmount = ONE_ETH;
    const unlockTime = (await time.latest()) + ONE_HOUR_IN_SEC;

    console.log(
      "Amount will be unloaked at : ",
      new Date(unlockTime * 1000).toLocaleTimeString()
    );

    const [owner, otherAccount] = await ethers.getSigners();

    console.log("First Account ", owner.address);
    console.log("Second Account ", otherAccount.address);

    const wei = await ethers.provider.getBalance(owner);
    console.log("Owner current balance : ", await ethers.formatEther(wei));
    const CallContract = await ethers.getContractFactory("Lock");

    const CONTRACT = await CallContract.deploy(unlockTime, {
      value: lockedAmount,
    });

    console.log("Contract hash", await CONTRACT.getAddress());
    console.log(
      "Contract balance : ",
      await ethers.formatEther(await ethers.provider.getBalance(CONTRACT))
    );

    return { CONTRACT, unlockTime, lockedAmount, owner, otherAccount };
  };

  describe("Deployment", () => {
    //  run setup before each it.
    beforeEach(async () => {
      ({ CONTRACT, owner, unlockTime, lockedAmount } = await loadFixture(
        deployOneHourLockFixture
      ));
    });

    // run actual test case
    it("Should set the right unlockTime", async () => {
      expect(await CONTRACT.unlockTime()).to.equal(unlockTime);
    });

    it("Should set the right owner", async () => {
      expect(await CONTRACT.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async () => {
      expect(await ethers.provider.getBalance(CONTRACT.target)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async () => {
      const latestTime = await time.latest();

      const Lock = await ethers.getContractFactory("Lock");

      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    });
  });

  describe("Withdrawals", () => {
    describe("Validations", () => {
      it("Should revert with the right error if called too soon", async () => {
        const { CONTRACT } = await loadFixture(deployOneHourLockFixture);

        await expect(CONTRACT.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async () => {
        const { CONTRACT, unlockTime, otherAccount } = await loadFixture(
          deployOneHourLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(
          CONTRACT.connect(otherAccount).withdraw()
        ).to.be.revertedWith("You aren't the owner");
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async () => {
        const { CONTRACT, unlockTime } = await loadFixture(
          deployOneHourLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(CONTRACT.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", () => {
      it("Should emit an event on withdrawals", async () => {
        const { CONTRACT, unlockTime, lockedAmount } = await loadFixture(
          deployOneHourLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(CONTRACT.withdraw())
          .to.emit(CONTRACT, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", () => {
      it("Should transfer the funds to the owner", async () => {
        const { CONTRACT, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneHourLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(CONTRACT.withdraw()).to.changeEtherBalances(
          [owner, CONTRACT],
          [lockedAmount, -lockedAmount]
        );

        const wei = await ethers.provider.getBalance(owner);
        console.log("Owner new balance : ", await ethers.formatEther(wei));
      });
    });
  });
});
