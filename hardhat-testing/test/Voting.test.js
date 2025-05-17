const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployERC20 } = require("./utils/ERC20");
const { ZeroAddress } = require("ethers");

describe("Voting", () => {
  const deployVotingContract = async () => {
    const Contract = await ethers.getContractFactory("Voting");
    const [owner, candidate1, candidate2, voter1, voter2, voter3, voter4] =
      await ethers.getSigners();
    const { pkbk_deployedContract, token_marketplace_deplyedContract } =
      await deployERC20();
    const voting_deployedContract = await Contract.deploy(
      pkbk_deployedContract.target
    );
    await voting_deployedContract.waitForDeployment(); // for contract deployment
    return {
      voting_deployedContract,
      owner,
      candidate1,
      candidate2,
      voter1,
      voter2,
      voter3,
      voter4,
      token_marketplace_deplyedContract,
      pkbk_deployedContract,
    };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({
        voting_deployedContract,
        owner,
        candidate1,
        candidate2,
        voter1,
        voter2,
        voter3,
        voter4,
        token_marketplace_deplyedContract,
        pkbk_deployedContract,
      } = await loadFixture(deployVotingContract));
    });

    it("Should set election commission", async () => {
      expect(await voting_deployedContract.electionCommission()).to.equal(
        owner.address
      );
    });

    describe("Registration", () => {
      it("Should register the candidate", async () => {
        candidateName = "Imran Qureshi";
        party = "Justice Alliance Party";
        age = 45;
        gender = 0;

        await voting_deployedContract
          .connect(candidate1)
          .registerCandidate(candidateName, party, age, gender);
        const candidateList = await voting_deployedContract.getCandidateList();
        expect(candidateList.length).to.be.above(0);
      });

      it("Should register the voter", async () => {
        voterName = "Bilal Ahmad";
        age = 28;
        gender = 0;
        await voting_deployedContract
          .connect(voter1)
          .registerVoter(voterName, age, gender);

        const votersList = await voting_deployedContract.getVotersList();
        expect(votersList.length).to.be.above(0);
      });
    });

    describe("Voting Period", () => {
      it("Should set the voting time", async () => {
        const startAt = 0;
        const endAfter = 3600;
        await voting_deployedContract.setVotingPeriod(startAt, endAfter);

        expect(parseInt(await voting_deployedContract.startTime())).to.equal(
          (await time.latest()) + startAt
        );
        expect(parseInt(await voting_deployedContract.endTime())).to.equal(
          (await time.latest()) + endAfter
        );
      });
    });

    describe("States Updates", () => {
      it("Should declare status", async () => {
        await voting_deployedContract.emergencyStopVoting();
        expect(await voting_deployedContract.stopVoting()).to.equal(true);
      });

      it("Should check the winner", async () => {
        expect(await voting_deployedContract.winner()).to.equal(ZeroAddress);
      });

      it("Should check voting status", async () => {
        expect(
          parseInt(await voting_deployedContract.getVotingStatus())
        ).to.equal(0); // voting not started
      });
    });

    describe("Performing Voting", () => {
      it("Should perform proper voting", async () => {
        // --- Register Candidates ---
        await voting_deployedContract
          .connect(candidate1)
          .registerCandidate("Imran Qureshi", "Justice Alliance Party", 45, 0);

        await voting_deployedContract
          .connect(candidate2)
          .registerCandidate(
            "Kashif Mehmood",
            "People's Reform Movement",
            42,
            0
          );

        // --- Register Voters ---
        await voting_deployedContract
          .connect(voter1)
          .registerVoter("Bilal Ahmad", 28, 0);

        await voting_deployedContract
          .connect(voter2)
          .registerVoter("Noman Siddiqui", 33, 0);

        await voting_deployedContract
          .connect(voter3)
          .registerVoter("Usman Farooq", 29, 0);

        await voting_deployedContract
          .connect(voter4)
          .registerVoter("Hamza Yousuf", 35, 0);

        // --- Buy Tokens ---
        const tokens = 1n * 10n ** 18n;

        let tokenPrice =
          await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
            tokens
          );
        await token_marketplace_deplyedContract
          .connect(voter1)
          .buyPKBKToken(tokens, { value: tokenPrice });

        tokenPrice =
          await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
            tokens
          );
        await token_marketplace_deplyedContract
          .connect(voter2)
          .buyPKBKToken(tokens, { value: tokenPrice });

        tokenPrice =
          await token_marketplace_deplyedContract.calculateTokenPrice.staticCall(
            tokens
          );
        await token_marketplace_deplyedContract
          .connect(voter3)
          .buyPKBKToken(tokens, { value: tokenPrice });

        // --- Set Voting Period ---
        const startAt = 0;
        const endAfter = 3600;
        await voting_deployedContract.setVotingPeriod(startAt, endAfter);
        const endTime = await voting_deployedContract.endTime();

        // --- Cast Votes ---
        await voting_deployedContract.connect(voter1).castVote(1, 1);
        await voting_deployedContract.connect(voter2).castVote(2, 1);
        await voting_deployedContract.connect(voter3).castVote(3, 2);

        // --- Simulate End of Voting Period ---
        await time.increaseTo(parseInt(endTime) + 1);

        // --- Optional: Uncomment to test vote rejection after endTime ---
        // await voting_deployedContract.connect(voter4).castVote(4, 2);

        // --- Output Lists and Declare Result ---
        //console.log(await voting_deployedContract.getVotersList());
        //console.log(await voting_deployedContract.getCandidateList());

        await voting_deployedContract.announceVotingResult();
        // console.log(await voting_deployedContract.winner());
      });
    });
  });
});
