const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", () => {
  const deployVotingContract = async () => {
    const Contract = await ethers.getContractFactory("Voting");
    const [owner, candidate, voter] = await ethers.getSigners();
    const voting_deployedContract = await Contract.deploy();
    await voting_deployedContract.waitForDeployment();
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
      beforeEach(async () => {
        ({ voting_deployedContract, owner } = await loadFixture(
          deployVotingContract
        ));
      });

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

    describe("", () => {});
  });
});
