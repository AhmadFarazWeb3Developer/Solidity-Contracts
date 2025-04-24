//SPDX-License-Identifier: MIT
pragma soldity ^0.8.22;

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
    uint startTime;
    uint endTime;
    bool stopVoting;

    // making a variable or function private does not mean its not visiable,
    // its there in bytecode in blockchain , just access gets limited
    // we can store the struct in array but its get expensive while iterating

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
            _gender,
            nextCandidateId,
            msg.sender,
            0
        );
        nextCandidateId++;
    }

    function registerVoter(
        string calldata _name,
        string _age,
        Gender _gender,
        uint _voteCandidateId
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
        for (i = 1; i < nextCandidateId; i++) {
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

    function startVoting() {}
    function endVoting() {}
    function getVotingStatus() public view returns (votingStatus) {}
    function announceVotingResult() external onlyCommissioner {}
    function emergencyStopVoting() public onlyCommissioner {
        stopVoting = true;
    }
}
