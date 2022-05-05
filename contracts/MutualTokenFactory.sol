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
     mapping(address => UserState) userStates;

     mapping(address => UserProposal) userJoinedProposal;

     ProposalConfig config;

    constructor() {
        mutualToken = new MutualToken();
        escrowToken = new MutualEscrowToken();
        config.acceptedCountLimit = 0;
        config.rejectedCountLimit = 1;
    }

    function join(uint8 amount, string calldata description) public returns(address _proposalAddress) {
        require(!userStates[msg.sender].joined, "account had been joined.");
        if(userJoinedProposal[msg.sender].exists) {
            return address(userJoinedProposal[msg.sender].proposal);
        
        }

        UserActivityProposal proposal = new UserActivityProposal(description, amount,  owner(), config.acceptedCountLimit, config.rejectedCountLimit);
        userJoinedProposal[msg.sender].proposal = proposal;

        return address(userJoinedProposal[msg.sender].proposal);
    } 

    function accept(address to) public returns(IUserActivityProposal.Stage stage) {
        return IUserActivityProposal(to).vote(true);
    }

    function reject(address to) public returns(IUserActivityProposal.Stage stage) {
        return IUserActivityProposal(to).vote(false);
    }

}