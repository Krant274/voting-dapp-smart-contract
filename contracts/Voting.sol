// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    struct Candidate {
        uint id;
        string name;
        string description;
        uint voteCount;
    }
    
    address public admin;
    bool public votingActive;
    uint public currentElectionId;

    mapping(uint => mapping(uint => Candidate)) public candidates;
    mapping(uint => uint) public candidatesCount;
    mapping(uint => mapping(address => bool)) public hasVoted;

    event ElectionStarted(uint electionId);
    event ElectionStopped(uint electionId);
    event VoteCasted(uint electionId, address voter, uint candidateId);
    event CandidateRegistered(uint electionId, string name);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Chi admin moi co quyen");
        _;
    }

    constructor() {
        admin = msg.sender;
        currentElectionId = 0;
        votingActive = false;
    }

    function startNewElection() public onlyAdmin {
        if (votingActive) votingActive = false;
        currentElectionId++;
        votingActive = true;
        emit ElectionStarted(currentElectionId);
    }

    function stopVoting() public onlyAdmin {
        votingActive = false;
        emit ElectionStopped(currentElectionId);
    }

    function registerCandidate(string memory _name, string memory _description) public onlyAdmin {
        uint cCount = candidatesCount[currentElectionId];
        cCount++;
        candidates[currentElectionId][cCount] = Candidate(cCount, _name, _description, 0);
        candidatesCount[currentElectionId] = cCount;
        emit CandidateRegistered(currentElectionId, _name);
    }

    function vote(uint _candidateId) public {
        require(votingActive, "Bau cu dang dong");
        require(!hasVoted[currentElectionId][msg.sender], "Ban da bo phieu");
        require(_candidateId > 0 && _candidateId <= candidatesCount[currentElectionId], "ID sai");

        hasVoted[currentElectionId][msg.sender] = true;
        candidates[currentElectionId][_candidateId].voteCount++;
        emit VoteCasted(currentElectionId, msg.sender, _candidateId);
    }

    function getResults() public view returns (uint[] memory, string[] memory, string[] memory, uint[] memory) {
        uint cCount = candidatesCount[currentElectionId];
        uint[] memory ids = new uint[](cCount);
        string[] memory names = new string[](cCount);
        string[] memory descs = new string[](cCount);
        uint[] memory votes = new uint[](cCount);

        for (uint i = 1; i <= cCount; i++) {
            Candidate storage c = candidates[currentElectionId][i];
            ids[i-1] = c.id;
            names[i-1] = c.name;
            descs[i-1] = c.description;
            votes[i-1] = c.voteCount;
        }
        return (ids, names, descs, votes);
    }

    function getWinner() public view returns (string[] memory winnerNames, uint winnerVotes) {
        uint maxVotes = 0;
        uint cCount = candidatesCount[currentElectionId];
        if (cCount == 0) return (new string[](0), 0);

        for (uint i = 1; i <= cCount; i++) {
            if (candidates[currentElectionId][i].voteCount > maxVotes) {
                maxVotes = candidates[currentElectionId][i].voteCount;
            }
        }

        uint count = 0;
        for (uint i = 1; i <= cCount; i++) {
            if (candidates[currentElectionId][i].voteCount == maxVotes) {
                count++;
            }
        }

        winnerNames = new string[](count);
        uint index = 0;
        for (uint i = 1; i <= cCount; i++) {
            if (candidates[currentElectionId][i].voteCount == maxVotes) {
                winnerNames[index] = candidates[currentElectionId][i].name;
                index++;
            }
        }
        return (winnerNames, maxVotes);
    }
}