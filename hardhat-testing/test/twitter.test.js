const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const { expect } = require("chai");

describe("Twitter", () => {
  const deployTwitterContract = async () => {
    const CONTRACT = await ethers.getContractFactory("Twitter");

    const [acct1, acct2, acct3, acct4] = await ethers.getSigners();
    const deployedContract = await CONTRACT.deploy();
    await deployedContract.waitForDeployment();

    return { deployedContract, acct1, acct2, acct3, acct4 };
  };

  describe("Tweets", () => {
    beforeEach(async () => {
      ({ deployedContract, acct1, acct2, acct3, acct4 } = await loadFixture(
        deployTwitterContract
      ));
    });

    it("Should publish tweet", async () => {
      await deployedContract.connect(acct1).tweet("This is my first tweet");
      await deployedContract.connect(acct2).tweet("This is my second tweet");
      await deployedContract.connect(acct3).tweet("This is my third tweet");
      await deployedContract.connect(acct4).tweet("This is my fourth tweet");
      //   console.log("Tweets : ", await deployedContract.getLatestTweets(4));

      expect(await deployedContract.getLatestTweets(4)).to.have.lengthOf(4);
      expect(
        await deployedContract.getLatestTweetsOf(acct1, 1)
      ).to.have.lengthOf(1);
    });

    it("Should tweet onbehalf of other", async () => {
      // allow
      await deployedContract.connect(acct1).allow(acct2);
      await deployedContract
        .connect(acct2)
        .tweetOnBehalf(acct1, "Hey, Ahmad Faraz is tweeting");
      //   console.log(await deployedContract.getLatestTweetsOf(acct1, 1));
      expect(
        await deployedContract.getLatestTweetsOf(acct1, 1)
      ).to.have.lengthOf(1);

      // disallow
      await deployedContract.connect(acct1).disallow(acct2);
      await expect(
        deployedContract
          .connect(acct2)
          .tweetOnBehalf(acct1, "Hey, Ahmad Faraz is tweeting")
      ).to.be.revertedWith("Unauthorized");
    });
  });

  describe("Messages", () => {
    beforeEach(async () => {
      ({ deployedContract } = await loadFixture(deployTwitterContract));
    });

    it("Should send Message", async () => {
      await deployedContract
        .connect(acct1)
        .sendMessage("Hey, Ahmad Faraz is here", acct2);

      await deployedContract
        .connect(acct1)
        .sendMessage("Hey, Ahmad Faraz is here", acct3);
      await deployedContract
        .connect(acct1)
        .sendMessage("Hey, Ahmad Faraz is here", acct4);
      //   console.log(await deployedContract.getMessagesOf(acct1));
      expect(await deployedContract.getMessagesOf(acct1)).to.have.lengthOf(3);
    });

    it("Should message onbehalf of other", async () => {
      await deployedContract.connect(acct1).allow(acct2);
      await deployedContract
        .connect(acct2)
        .sendMessageOnBehalf(
          acct1,
          acct3,
          "Hey, Ahmad Faraz assistant talking"
        );
      //   console.log(await deployedContract.getMessagesOf(acct1));
      expect(await deployedContract.getMessagesOf(acct1)).to.have.lengthOf(1);

      // disallow
      await deployedContract.connect(acct1).disallow(acct2);
      await expect(
        deployedContract
          .connect(acct2)
          .sendMessageOnBehalf(
            acct1,
            acct3,
            "Hey, Ahmad Faraz assistant is talking again"
          )
      ).to.be.revertedWith("Unauthorized");
    });
  });

  describe("following", () => {
    beforeEach(async () => {
      ({ deployedContract } = await loadFixture(deployTwitterContract));
    });

    it("should follow other accounts", async () => {
      await deployedContract.connect(acct1).follow(acct2);
      await deployedContract.connect(acct1).follow(acct3);
      await deployedContract.connect(acct1).follow(acct4);
      expect(
        await deployedContract.connect(acct1).getFollowingList()
      ).to.have.lengthOf(3);
    });
  });
});
