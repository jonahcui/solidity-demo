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

    constructor() {
        mutualToken = new MutualToken();
        escrowToken = new MutualEscrowToken();
        config.acceptedCountLimit = 0;
        config.rejectedCountLimit = 1;
    }

    event ProposalReCreated(address contractAddress);

    event ProposalCreated(address contractAddress);

    event ProposalDone(address proposal);

    event ProposalReject(address proposal);

    function join(uint256 amount, string calldata description) public returns(address _proposalAddress) {
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
        IUserActivityProposal proposal = IUserActivityProposal(to);
       IUserActivityProposal.Stage stage = proposal.vote(true);
       if(stage == IUserActivityProposal.Stage.Done) {
           uint256 tokenAmount = proposal.getAmount() / 2;
           uint256 escrowTokenAmount = proposal.getAmount() - tokenAmount;

           mutualToken.mint(proposal.getUser(), tokenAmount);
           escrowToken.mint(proposal.getUser(), escrowTokenAmount);

           emit ProposalDone(to);
       }
    }

    function reject(address to) public returns(IUserActivityProposal.Stage stage) {
        return IUserActivityProposal(to).vote(false);
    }

    function getTokenAddress() public view returns (address _address) {
        return address(mutualToken);
    }

    function getEscrowTokenAddress() public view returns (address _address) {
        return address(escrowToken);
    }

}