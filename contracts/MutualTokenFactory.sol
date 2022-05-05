// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MutualToken.sol";
import "./MutualEscrowToken.sol";
import "./UserActivityProposal.sol";

contract MutualTokenFactory is Ownable {

    struct ProposalConfig {
        uint8 acceptedCountLimit;
        uint8 rejectedCountLimit;
    }

    struct UserState {
        address user;
        string info;
        bool joined;
    }

    struct UserProposal {
        address user;
        UserActivityProposal proposal;
        bool exists;
    }

     MutualToken mutualToken;
     MutualEscrowToken escrowToken;

     mapping(address => UserState) public userStates;

     mapping(address => UserProposal) public userJoinedProposal;

     ProposalConfig config;

    constructor() Ownable() {
        mutualToken = new MutualToken();
        escrowToken = new MutualEscrowToken();
        config.acceptedCountLimit = 0;
        config.rejectedCountLimit = 1;
    }

    event ProposalReCreated(address to);

    event ProposalCreated(address to);

    event ProposalDone(address to);

    event ProposalReject(address to);

    function join(uint256 amount, string calldata description) public returns(address _proposalAddress) {
        require(owner() != msg.sender, "manager can not join");
        require(!userStates[msg.sender].joined, "account had been joined.");

        if(userJoinedProposal[msg.sender].exists) {
            emit ProposalReCreated(address(userJoinedProposal[msg.sender].proposal));
            return address(userJoinedProposal[msg.sender].proposal);
        }

        UserActivityProposal proposal = new UserActivityProposal(msg.sender, description, amount,  owner(), config.acceptedCountLimit, config.rejectedCountLimit);
        userJoinedProposal[msg.sender].proposal = proposal;
        userJoinedProposal[msg.sender].exists = true;

        emit ProposalCreated(address(proposal));
        return address(userJoinedProposal[msg.sender].proposal);
    } 

    function accept(address to) public {
       require(msg.sender == owner() || userStates[msg.sender].joined, "user must owner or user had been joined.");
       require(msg.sender != to, "user can only vote for other users");
       require(userJoinedProposal[to].exists, "proposal exists");

       UserActivityProposal proposal = userJoinedProposal[to].proposal;
       UserActivityProposal.Stage stage = proposal.vote(msg.sender, true);
       if(stage == UserActivityProposal.Stage.Done) {
           uint256 tokenAmount = proposal.getAmount() / 2;
           uint256 escrowTokenAmount = proposal.getAmount() - tokenAmount;

           mutualToken.mint(to, tokenAmount);
           escrowToken.mint(to, escrowTokenAmount);

           userStates[to].user = proposal.getUser();
           userStates[to].info = proposal.getInfo();
           userStates[to].joined = true;

           emit ProposalDone(to);
       }
    }

    function reject(address to) public returns(UserActivityProposal.Stage stage) {
       require(msg.sender == owner() || userStates[msg.sender].joined, "user must owner or user had been joined.");
       require(msg.sender != to, "user can only vote for other users");
       require(userJoinedProposal[to].exists, "proposal exists");
       UserActivityProposal proposal = userJoinedProposal[to].proposal;
       stage = proposal.vote(msg.sender, false);
       if(stage == UserActivityProposal.Stage.Reject) {
           userJoinedProposal[to].exists = false;
           emit ProposalReject(to);
       }
    }

    function getTokenAddress() public view returns (address _address) {
        return address(mutualToken);
    }

    function getEscrowTokenAddress() public view returns (address _address) {
        return address(escrowToken);
    }

}