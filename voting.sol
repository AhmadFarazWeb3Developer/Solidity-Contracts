//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Voting {
    struct Voter {
        string name;
        uint age;
        uint voterId;
        Gender gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint age;
        Gender gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }

    // third entity
    address electionCommission;

    address public winner;
    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;
    uint endTime;
    bool stopVoting;

    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;

    // representing integer values in names are "Enums"
    enum Gender {
        Male,
        Female,
        NotSpecified,
        Other
    }
    enum VotingStatus {
        NotStarted, // 0
        InProgress, // 1
        Ended // 2
    }

    constructor() {
        electionCommission = msg.sender;
    }
    modifier isVotingOver() {
        require(
            block.timestamp <= endTime && stopVoting == false,
            "Voting Over"
        );
        _;
    }
    modifier onlyCommissioner() {
        require(msg.sender == electionCommission, "Not Authorized");
        _;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    ) external {
        require(_age >= 18, "You are under 18");
        require(
            isCandidateNotRegistered(msg.sender),
            "Your are aleady registered"
        );
        require(nextCandidateId < 3, "Candidate Registration Full"); // There is election between two candidates only
        candidateDetails[nextCandidateId] = Candidate(
            _name,
            _party,
            _age,
            _gender,
            nextCandidateId,
            msg.sender,
            0
        );
        nextCandidateId++;
    }

    function registerVoter(
        string calldata _name,
        uint _age,
        Gender _gender
    ) external {
        voterDetails[nextVoterId] = Voter(
            _name,
            _age,
            nextVoterId,
            _gender,
            0,
            msg.sender
        );
        nextVoterId;
    }

    function isCandidateNotRegistered(
        address _person
    ) internal view returns (bool) {
        for (uint i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }
        return true;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1); //initialize an empty array of length = `nextCandidateId - 1`
        for (uint i = 0; i < candidateList.length; i++) {
            candidateList[i] = candidateDetails[i + 1];
        }
        return candidateList;
    }

    function getVotersList() public view returns (Voter[] memory) {
        Voter[] memory voterList = new Voter[](nextVoterId - 1);
        for (uint i = 0; i < voterList.length; i++) {
            voterList[i] = voterDetails[i + 1];
        }
        return voterList;
    }

    function castVote(uint _voterId, uint _candidateId) public {
        require(
            voterDetails[_voterId].voteCandidateId == 0,
            "You are already Voted"
        );
        require(
            voterDetails[_voterId].voterAddress == msg.sender,
            "Not Authorized Voter"
        );
        require(
            _candidateId >= 1 && _candidateId < 3,
            "Candidate Id doesn't exists"
        );

        voterDetails[_voterId].voteCandidateId = _candidateId;
        candidateDetails[_candidateId].votes++;
    }

    function setVotingPeriod(
        uint _startTimeDuration,
        uint _endTimeDuration
    ) external onlyCommissioner {
        require(_endTimeDuration > 3600, "must be greater then 1 hour ");
        startTime = block.timestamp + _startTimeDuration;
        endTime = _startTimeDuration + _endTimeDuration;
    }

    function getVotingStatus() public view returns (VotingStatus) {
        if (startTime == 0) {
            return VotingStatus.NotStarted;
        } else if (endTime > block.timestamp && stopVoting == false) {
            return VotingStatus.InProgress;
        } else {
            return VotingStatus.Ended;
        }
    }

    function announceVotingResult() external onlyCommissioner {
        uint max = 0;
        for (uint i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].votes > max) {
                max = candidateDetails[i].votes;
                winner = candidateDetails[i].candidateAddress;
            }
        }
    }

    function emergencyStopVoting() public onlyCommissioner {
        stopVoting = true;
    }

    // function startVoting() {}
    // function endVoting() {}
}
