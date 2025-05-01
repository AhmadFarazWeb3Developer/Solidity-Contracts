const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", () => {
  const deployVotingContract = async () => {
    const Contract = await ethers.getContractFactory("Voting");
    const [owner, candidate, voter] = await ethers.getSigners();
    const voting_deployedContract = await Contract.deploy();
    await voting_deployedContract.waitForDeployment(); // for contract deployment
    // console.log(voting_deplyedContract);
    return { voting_deployedContract, owner, candidate, voter };
  };

  describe("Deployment", () => {
    beforeEach(async () => {
      ({ voting_deployedContract, owner, candidate, voter } = await loadFixture(
        deployVotingContract
      ));
    });
    it("Should set election commission", async () => {
      expect(await voting_deployedContract.electionCommission()).to.equal(
        owner.address
      );
    });

    describe("Registeration", () => {
      //   beforeEach(async () => {
      //     ({ voting_deployedContract, owner } = await loadFixture(
      //       deployVotingContract
      //     ));
      //   });

      it("Should register the candidate", async () => {
        candidateName = "Saqib Khan";
        party = "PCP";
        age = parseInt(30);
        gender = 0;

        await voting_deployedContract
          .connect(candidate)
          .registerCandidate(candidateName, party, age, gender);
        const candidateList = await voting_deployedContract.getCandidateList();
        expect(candidateList.length).to.above(0);
      });

      it("Should register the voter", async () => {
        voterName = "Ahmad Faraz";
        age = parseInt(30);
        gender = 0;
        await voting_deployedContract
          .connect(voter)
          .registerVoter(voterName, age, gender);
        const votersList = await voting_deployedContract.getVotersList();
        expect(votersList.length).to.above(0);
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
      it("should check voting status", async () => {
        expect(
          parseInt(await voting_deployedContract.getVotingStatus())
        ).to.equal(0); // voting not started
      });
        
        
    });
  });
});
