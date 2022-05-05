// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IUserActivityProposal {
    enum Stage {
        Init, Voted, Done, Reject
    }

    function vote(bool accepted) external returns(Stage _stage);

    function getUser() external view returns(address _address);
    function getAmount() external view returns (uint256 amount);
}

contract UserActivityProposal is IUserActivityProposal {

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
    uint8 public acceptedCounts;
    uint8 public rejectCounts;


    mapping(address => Vote) voters;



    modifier onlyManager() {
        require(msg.sender == manager, "only manager can operate.");
        _;
    }

    modifier onlyStage(Stage _stage) {
        require(stage == _stage, "current stage can not operate");
        _;
    }

    constructor(address _user, string memory _name, uint256 _amount, address _manager, uint8 _acceptedCountsLimit, uint8 _rejectCountsLimit) {
        manager = _manager;
        user=_user;
        name = _name;
        acceptedCountsLimit = _acceptedCountsLimit;
        rejectCountsLimit = _rejectCountsLimit;
        amount = _amount;
    }

    function vote(bool accepted) external override returns(Stage _stage) {
        require(!voters[msg.sender].voted || msg.sender == manager);

        if(msg.sender == manager) {
            managerAgreed = true;
        } else if(accepted) {
            acceptedCounts = acceptedCounts + 1;
            voters[msg.sender].voted = true;
            voters[msg.sender].accepted = true;
        } else {
            acceptedCounts = acceptedCounts + 1;
            voters[msg.sender].voted = true;
            voters[msg.sender].accepted = true;
        }

        if(managerAgreed && acceptedCounts >= acceptedCountsLimit) {
            stage = Stage.Done;
        }

        if(!managerAgreed || rejectCounts >= rejectCountsLimit) {
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

}