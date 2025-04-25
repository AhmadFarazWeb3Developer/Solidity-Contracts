//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Voting {
    struct Voter {
        string name;
        uint256 age;
        uint256 voterId;
        Gender gender;
        uint256 voteCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint256 age;
        Gender gender;
        uint256 candidateId;
        address candidateAddress;
        uint256 votes;
    }

    // third entity
    address electionCommission;

    address public winner;

    uint256 nextVoterId = 1;
    uint256 nextCandidateId = 1;
    uint256 startTime;
    uint256 endTime;
    bool stopVoting;

    mapping(uint256 => Voter) voterDetails;
    mapping(uint256 => Candidate) candidateDetails;

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
            block.timestamp >= startTime &&
                block.timestamp <= endTime &&
                !stopVoting,
            "Voting period is not active"
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
        uint256 _age,
        Gender _gender
    ) external {
        require(_age >= 18, "Age must be 18 or older");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_party).length > 0, "Party cannot be empty");
        require(
            isCandidateNotRegistered(msg.sender),
            "Already registered as candidate"
        );
        require(nextCandidateId < 3, "Maximum candidates reached"); // There is election between two candidates only

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

        emit CandidateRegistered(msg.sender, _name);
    }

    function registerVoter(
        string calldata _name,
        uint256 _age,
        Gender _gender
    ) external {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_age >= 18, "Must be 18 or older");
        require(isVoterRegistered(msg.sender), "Already registered as voter");
        voterDetails[nextVoterId] = Voter(
            _name,
            _age,
            nextVoterId,
            _gender,
            0,
            msg.sender
        );
        nextVoterId++;
        emit VoterRegistered(msg.sender, _name);
        // event VoterRegistered(address indexed voter, string name);
    }

    function isCandidateNotRegistered(
        address _person
    ) internal view returns (bool) {
        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }
        return true;
    }

    // is voter registered ?

    function isVoterRegistered(address _person) internal view returns (bool) {
        for (uint256 i = 0; i < nextVoterId; i++) {
            if (voterDetails[i].voterAddress == _person) {
                return false;
            }
        }
        return true;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1); //initialize an empty array of length = `nextCandidateId - 1`
        for (uint256 i = 0; i < candidateList.length; i++) {
            candidateList[i] = candidateDetails[i + 1];
        }
        return candidateList;
    }

    function getVotersList() public view returns (Voter[] memory) {
        Voter[] memory voterList = new Voter[](nextVoterId - 1);
        for (uint256 i = 1; i < voterList.length; i++) {
            voterList[i] = voterDetails[i + 1];
        }
        return voterList;
    }

    function castVote(
        uint256 _voterId,
        uint256 _candidateId
    ) public isVotingOver {
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

        emit VoteCast(msg.sender, _candidateId);
        // event VoteCast(address indexed voter, uint256 candidateId);
    }

    function setVotingPeriod(
        uint256 _startTimeDuration,
        uint256 _endTimeDuration
    ) external onlyCommissioner {
        require(
            _endTimeDuration >= 3600,
            "Duration must be greater or equal to 1 hour "
        );
        startTime = block.timestamp + _startTimeDuration;
        endTime = startTime + _endTimeDuration;

        emit VotingPeriodSet(startTime, endTime);
        // event VotingPeriodSet(uint256 startTime, uint256 endTime);
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
        uint256 max = 0;
        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].votes > max) {
                max = candidateDetails[i].votes;
                winner = candidateDetails[i].candidateAddress;
            }
        }
        stopVoting = true;
    }

    function emergencyStopVoting() public onlyCommissioner {
        stopVoting = true;
    }

    // Events for tracking activity
    event CandidateRegistered(address indexed candidate, string name);
    event VoterRegistered(address indexed voter, string name);
    event VoteCast(address indexed voter, uint256 candidateId);
    event VotingPeriodSet(uint256 startTime, uint256 endTime);
}

// start time:  1745602733 + 3600
// end time:    1745609933
