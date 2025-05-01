const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", () => {
  const deployVotingContract = async () => {
    const Contract = await ethers.getContractFactory("Voting");
    const [owner, candidate1, candidate2, voter1, voter2, voter3, voter4] =
      await ethers.getSigners();
    const voting_deployedContract = await Contract.deploy();
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
        expect(await voting_deployedContract.winner()).to.equal(
          "0x0000000000000000000000000000000000000000"
        );
      });

      it("Should check voting status", async () => {
        expect(
          parseInt(await voting_deployedContract.getVotingStatus())
        ).to.equal(0); // voting not started
      });
    });

    describe("Performing Voting", () => {
      it("Should perform proper voting", async () => {
        // Register Candidates
        candidateName = "Imran Qureshi";
        party = "Justice Alliance Party";
        age = 45;
        gender = 0;

        await voting_deployedContract
          .connect(candidate1)
          .registerCandidate(candidateName, party, age, gender);

        candidateName = "Kashif Mehmood";
        party = "People's Reform Movement";
        age = 42;
        gender = 0;

        await voting_deployedContract
          .connect(candidate2)
          .registerCandidate(candidateName, party, age, gender);

        // Register Voters
        voterName = "Bilal Ahmad";
        age = 28;
        gender = 0;
        await voting_deployedContract
          .connect(voter1)
          .registerVoter(voterName, age, gender);

        voterName = "Noman Siddiqui";
        age = 33;
        gender = 0;
        await voting_deployedContract
          .connect(voter2)
          .registerVoter(voterName, age, gender);

        voterName = "Usman Farooq";
        age = 29;
        gender = 0;
        await voting_deployedContract
          .connect(voter3)
          .registerVoter(voterName, age, gender);

        voterName = "Hamza Yousuf";
        age = 35;
        gender = 0;
        await voting_deployedContract
          .connect(voter4)
          .registerVoter(voterName, age, gender);

        // Set voting period
        const startAt = 0;
        const endAfter = 3600;
        await voting_deployedContract.setVotingPeriod(startAt, endAfter);

        // console.log(await voting_deployedContract.startTime());
        // console.log(await voting_deployedContract.endTime());

        const endTime = await voting_deployedContract.endTime();

        await voting_deployedContract.connect(voter1).castVote(1, 1);
        await voting_deployedContract.connect(voter2).castVote(2, 1);
        // await voting_deployedContract.emergencyStopVoting();
        await voting_deployedContract.connect(voter3).castVote(3, 2);

        // To test after voting has ended, increase time
        // await time.increaseTo(parseInt(endTime) + 1); // +1 to safely go past end

        // This should fail if time is increased above endTime
        // await voting_deployedContract.connect(voter4).castVote(4, 2);

        // console.log(await voting_deployedContract.getVotersList());
        // console.log(await voting_deployedContract.getCandidateList());

        await voting_deployedContract.announceVotingResult();
        // console.log(await voting_deployedContract.winner());
      });
    });
  });
});
