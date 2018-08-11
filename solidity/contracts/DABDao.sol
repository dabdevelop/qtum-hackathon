pragma solidity ^0.4.11;

import './interfaces/IDAB.sol';
import './interfaces/IDABDao.sol';
import './interfaces/IProposal.sol';
import './interfaces/ISmartToken.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IDABDaoFormula.sol';
import './Owned.sol';
import './SafeMath.sol';

/*
    DAB DAO v0.1

    The DAB DAO contract
*/

contract DABDao is IDABDao, SafeMath {

    struct Proposal {
    bool isValid;
    }

    uint256 public proposalPrice;
    address[] public proposals;
    address public depositAgent;
    mapping (address => Proposal) public proposalStatus;

    IDAB public dab;
    IDABDaoFormula public formula;
    ISmartToken public depositToken;

    event LogPropose(uint256 _time, address _proposal);
    event LogSetDABFormula(uint256 _time, address _proposal);
    event LogAddLoanPlanFormula(uint256 _time, address _proposal);
    event LogDisableLoanPlanFormula(uint256 _time, address _proposal);
    event LogTransferDABOwnership(uint256 _time, address _proposal);
    event LogAcceptDABOwnership(uint256 _time, address _proposal);

/**
    @dev constructor

    @param _dab DAB contract
    @param _formula DAB DAO formula contract
*/
    function DABDao(
    IDAB _dab,
    IDABDaoFormula _formula)
    validAddress(_dab)
    validAddress(_formula) 
    {
        dab = _dab;
        formula = _formula;

        proposalPrice = 100 ether;
        depositAgent = dab.depositAgent();
        depositToken = dab.depositToken();
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

// validates msg sender is a valid proposal
    modifier validProposal(){
        IProposal proposal = IProposal(msg.sender);
        require(proposalStatus[proposal].isValid == true);
        _;
    }

// validates voted proposal is a valid proposal
    modifier validVote(IProposal _proposal){
        require(proposalStatus[_proposal].isValid == true);
        _;
    }

// validates support rate of msg sender is over the threshold
    modifier dao(uint256 _threshold){
        require(_threshold <= 100 && _threshold >= 50);
        uint256 vote = depositToken.balanceOf(msg.sender);
        uint256 supply = depositToken.totalSupply();
        uint256 balance = depositToken.balanceOf(depositAgent);
        uint256 circulation = safeSub(supply, balance);
        bool isApproved = formula.isApproved(circulation, vote, _threshold);
        require(isApproved);
        _;
    }

/**
    @dev propose a proposal
    cost proposal price of deposit token which paid to all deposit token holders

    @param _proposal the proposal
*/
    function propose(IProposal _proposal)
    public
    validAddress(_proposal) 
    {
        require(msg.sender == address(_proposal));
        _proposal.acceptOwnership();
        assert(depositToken.transferFrom(_proposal, depositAgent, proposalPrice));
        proposals.push(_proposal);
        proposalStatus[_proposal].isValid = true;
        LogPropose(now, _proposal);
    }

/**
    @dev vote a proposal
    will transfer the deposit token to the proposal and exchange to vote token which is controlled by the proposal

    @param _proposal the proposal
    @param _voteAmount the amount of vote to the proposal
*/
    function vote(IProposal _proposal, uint256 _voteAmount)
    public
    validAddress(_proposal)
    validAmount(_voteAmount)
    validVote(_proposal) 
    {
        assert(depositToken.transferFrom(msg.sender, _proposal, _voteAmount));
        _proposal.vote(msg.sender, _voteAmount);
    }

/**
    @dev set DAB formula
    need over 80% of support rate at least to execute this function

*/
    function setDABFormula()
    public
    validProposal
    dao(80) 
    {
        IProposal proposal = IProposal(msg.sender);
        address proposalContract = proposal.proposalContract();
        IDABFormula formula = IDABFormula(proposalContract);
        dab.setDABFormula(formula);
        proposalStatus[proposal].isValid = false;
        LogSetDABFormula(now, proposal);
    }

/**
    @dev add a Loan Plan Formula
    need over 80% of support rate at least to execute this function

*/
    function addLoanPlanFormula()
    public
    validProposal
    dao(80) 
    {
        IProposal proposal = IProposal(msg.sender);
        address proposalContract = proposal.proposalContract();
        ILoanPlanFormula formula = ILoanPlanFormula(proposalContract);
        dab.addLoanPlanFormula(formula);
        proposalStatus[proposal].isValid = false;
        LogAddLoanPlanFormula(now, proposal);
    }

/**
    @dev disable a Loan Plan Formula
    need over 80% of support rate at least to execute this function

*/
    function disableLoanPlanFormula()
    public
    validProposal
    dao(80) 
    {
        IProposal proposal = IProposal(msg.sender);
        address proposalContract = proposal.proposalContract();
        ILoanPlanFormula formula = ILoanPlanFormula(proposalContract);
        dab.disableLoanPlanFormula(formula);
        proposalStatus[proposal].isValid = false;
        LogDisableLoanPlanFormula(now, proposal);
    }

/**
    @dev transfer DAB's ownership
    need over 80% of support rate at least to execute this function

*/
    function transferDABOwnership()
    public
    validProposal
    dao(80) 
    {
        IProposal proposal = IProposal(msg.sender);
        address proposalContract = proposal.proposalContract();
        dab.transferOwnership(proposalContract);
        proposalStatus[proposal].isValid = false;
        LogTransferDABOwnership(now, proposal);
    }

/**
    @dev accept DAB's ownership
    need over 50% of support rate at least to execute this function

*/
    function acceptDABOwnership()
    public
    validProposal
    dao(50) 
    {
        IProposal proposal = IProposal(msg.sender);
        dab.acceptOwnership();
        proposalStatus[proposal].isValid = false;
        LogAcceptDABOwnership(now, proposal);
    }

}
