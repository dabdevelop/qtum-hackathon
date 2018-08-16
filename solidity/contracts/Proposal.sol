pragma solidity ^0.4.11;

import './interfaces/IProposal.sol';
import './interfaces/ISmartToken.sol';
import './interfaces/IDABDao.sol';
import './Owned.sol';
import './SafeMath.sol';
import './SmartTokenController.sol';

/*
    DAB DAO Proposal v0.1

    Proposal to execute privilege functions in DAO
*/
contract Proposal is IProposal, Owned, SafeMath {

    address public proposalContract;
    uint256 public startTime;
    uint256 public endTime;

    uint256 public proposalPrice;

    IDABDao public dao;
    ISmartToken public depositToken;
    ISmartToken public voteToken;
    SmartTokenController public voteTokenController;

/**
    @dev constructor

    @param _dao      dao
    @param _voteTokenController      vote token controller
    @param _proposalContract      contract proposed in proposal
    @param _duration      duration of proposal
*/
    constructor(
    IDABDao _dao,
    SmartTokenController _voteTokenController,
    address _proposalContract,
    uint256 _duration)
    public
    validAddress(_dao)
    validAddress(_voteTokenController)
    validAmount(_duration) 
    {

        dao = _dao;
        voteTokenController = _voteTokenController;
        proposalContract = _proposalContract;
        startTime = now + 1 days;
        endTime = startTime + _duration;

        depositToken = dao.depositToken();
        proposalPrice = dao.proposalPrice();
        voteToken = voteTokenController.token();
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address){
        require(_address != 0x0);
        _;
    }

// verifies that an amount is greater than zero
    modifier validAmount(uint256 _amount){
        require(_amount > 0);
        _;
    }

// verifies that now is in propose stage
    modifier proposeStage(){
        require(now < startTime);
        _;
    }

// verifies that now is in vote stage
    modifier voteStage(){
        require(now > startTime && now < endTime);
        _;
    }

// verifies that now is in execute stage
    modifier excuteStage(){
        require(now > startTime);
        _;
    }

// verifies that now is in redeem stage
    modifier redeemStage(){
        require(now > startTime);
        _;
    }

/**
    @dev used by a new owner to accept a token controller ownership transfer
    can only be called by the contract owner
*/
    function acceptVoteTokenControllerOwnership() 
    public 
    ownerOnly
    {
        voteTokenController.acceptOwnership();
    }


/**
    @dev propose a new proposal to dao
    which will cost proposal price deposit token
*/
    function propose() 
    public 
    ownerOnly 
    proposeStage
    {
        uint256 voteTokenSupply = voteToken.totalSupply();
        require(voteTokenSupply == 0);
        depositToken.approve(dao, proposalPrice);
        transferOwnership(dao);
        dao.propose(this);
        startTime = now;
    }

/**
    @dev vote token issuance
*/
    function vote(address _voter, uint256 _voteAmount)
    public
    ownerOnly
    voteStage
    validAddress(_voter)
    validAmount(_voteAmount)
    {
        voteTokenController.issueTokens(_voter, _voteAmount);
    }

/**
    @dev deposit token redeem
*/
    function redeem() 
    public 
    redeemStage 
    {
        uint256 amount = voteToken.balanceOf(msg.sender);
        require(amount > 0);
        voteTokenController.destroyTokens(msg.sender, amount);
        depositToken.transfer(msg.sender, amount);
    }


}
