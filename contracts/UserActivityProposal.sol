// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract UserActivityProposal is Ownable {

    enum Stage {
        Voted, Done, Reject
    }

    struct Vote {
        address user;
        bool voted;
        bool accepted;
    }

    address manager;
    uint8 public acceptedCountsLimit;
    uint8 public rejectCountsLimit;
    address public user;
    string public name;
    uint256 public amount;
    Stage public stage;
    
    bool public managerAgreed;
    bool public managerVoted;
    uint8 public acceptedCounts;
    uint8 public rejectCounts;


    mapping(address => Vote) voters;

    modifier onlyStage(Stage _stage) {
        require(stage == _stage, "current stage can not operate");
        _;
    }

    constructor(address _user, string memory _name, uint256 _amount, address _manager, uint8 _acceptedCountsLimit, uint8 _rejectCountsLimit) Ownable(){
        manager = _manager;
        user=_user;
        name = _name;
        acceptedCountsLimit = _acceptedCountsLimit;
        rejectCountsLimit = _rejectCountsLimit;
        amount = _amount;
        stage = Stage.Voted;
    }

    function vote(address voter, bool accepted) public onlyOwner() onlyStage(Stage.Voted) returns(Stage _stage) {
        require(!voters[voter].voted || voter == manager, "user has been voted.");

        if(voter == manager) {
            managerVoted = true;
            managerAgreed = accepted;
        } else if(accepted) {
            acceptedCounts = acceptedCounts + 1;
            voters[voter].voted = true;
            voters[voter].accepted = true;
        } else {
            acceptedCounts = rejectCounts + 1;
            voters[voter].voted = true;
            voters[voter].accepted = false;
        }

        if(managerVoted && managerAgreed && acceptedCounts >= acceptedCountsLimit) {
            stage = Stage.Done;
        }

        if(managerVoted && !managerAgreed && rejectCounts >= rejectCountsLimit) {
            stage = Stage.Reject;
        }

        
        return stage;
    }


    function getStage() public view returns (Stage _stage) {
        return stage;
    }

     function getAmount() public view returns (uint256 _amount) {
         return amount;
     }

     function getUser() public view returns (address _user) {
         return user;
     }

     function getInfo() public view returns(string memory _info) {
         return name;
     }

}