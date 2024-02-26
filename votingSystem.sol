// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnhancedVotingSystem {
    struct Voter {
        bool hasVoted;
        uint256 voteWeight;
    }

    struct Proposal {
        string name;
        uint256 voteCount;
    }

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    uint256 public votingStartTime;
    uint256 public votingEndTime;
    uint256 public quorumPercentage;
    address public owner;

    event Voted(address indexed _voter, uint256 indexed _proposalIndex, uint256 _voteWeight);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 _votingDurationDays, uint256 _quorumPercentage, string[] memory _proposalNames) {
        require(_quorumPercentage > 0 && _quorumPercentage <= 100, "Quorum percentage must be between 1 and 100");
        require(_proposalNames.length > 0, "At least one proposal is required");

        owner = msg.sender;
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + (_votingDurationDays * 1 days);
        quorumPercentage = _quorumPercentage;

        for (uint256 i = 0; i < _proposalNames.length; i++) {
            proposals.push(Proposal({
                name: _proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function vote(uint256 _proposalIndex) external {
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Voting is not currently open");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_proposalIndex < proposals.length, "Invalid proposal index");

        voters[msg.sender].hasVoted = true;
        
        proposals[_proposalIndex].voteCount += voters[msg.sender].voteWeight;

        emit Voted(msg.sender, _proposalIndex, voters[msg.sender].voteWeight);
    }

    function addVoter(address _voterAddress, uint256 _voteWeight) external onlyOwner {
        require(_voterAddress != address(0), "Invalid address");
        require(!voters[_voterAddress].hasVoted, "Voter has already voted");

        voters[_voterAddress].hasVoted = false;
        voters[_voterAddress].voteWeight = _voteWeight;
    }

    function removeVoter(address _voterAddress) external onlyOwner {
        require(_voterAddress != address(0), "Invalid address");

        delete voters[_voterAddress];
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    function getProposal(uint256 _proposalIndex) external view returns (string memory, uint256) {
        require(_proposalIndex < proposals.length, "Invalid proposal index");

        Proposal memory proposal = proposals[_proposalIndex];
        return (proposal.name, proposal.voteCount);
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function getRemainingTime() external view returns (uint256) {
        if (block.timestamp <= votingEndTime) {
            return votingEndTime - block.timestamp;
        } else {
            return 0;
        }
    }

    function calculateQuorum() external view returns (uint256) {
        uint256 totalWeight = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            totalWeight += proposals[i].voteCount;
        }

        return (totalWeight * 100) / quorumPercentage;
    }

    function isVotingOpen() external view returns (bool) {
        return (block.timestamp >= votingStartTime && block.timestamp <= votingEndTime);
    }
}

