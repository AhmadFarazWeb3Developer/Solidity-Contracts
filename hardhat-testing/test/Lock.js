const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {
  async function deployOneHourLockFixture() {
    const ONE_HOUR_IN_SEC = 3600;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;

    const unlockTime = (await time.latest()) + ONE_HOUR_IN_SEC;

    const [owner, otherAccount] = await ethers.getSigners();

    const CallContract = await ethers.getContractFactory("Lock");

    const CONTRACT = await CallContract.deploy(unlockTime, {
      value: lockedAmount,
    });

    // console.log("lock ", CONTRACT);

    return { CONTRACT, unlockTime, lockedAmount, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { CONTRACT, unlockTime } = await loadFixture(
        deployOneHourLockFixture
      );

      expect(await CONTRACT.unlockTime()).to.equal(unlockTime);
    });

    it("Should set the right owner", async function () {
      const { CONTRACT, owner } = await loadFixture(deployOneHourLockFixture);

      expect(await CONTRACT.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async function () {
      const { CONTRACT, lockedAmount } = await loadFixture(
        deployOneHourLockFixture
      );

      expect(await ethers.provider.getBalance(CONTRACT.target)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async function () {
      const latestTime = await time.latest();

      const Lock = await ethers.getContractFactory("Lock");

      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    });
  });

  describe("Withdrawals", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { CONTRACT } = await loadFixture(deployOneHourLockFixture);

        await expect(CONTRACT.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
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

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { CONTRACT, unlockTime } = await loadFixture(
          deployOneHourLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(CONTRACT.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { CONTRACT, unlockTime, lockedAmount } = await loadFixture(
          deployOneHourLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(CONTRACT.withdraw())
          .to.emit(CONTRACT, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { CONTRACT, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneHourLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(CONTRACT.withdraw()).to.changeEtherBalances(
          [owner, CONTRACT],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });
});
