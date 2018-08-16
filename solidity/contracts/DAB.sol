pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './interfaces/IDABFormula.sol';
import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IDAB.sol';
import './DABOperationManager.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';
import './DABWalletFactory.sol';

/*
    DAB v0.1

    The DAB contract
*/

contract DAB is IDAB, DABOperationManager {

    struct Status {
        bool isValid;
    }

    string public version = "0.1";
    bool public isActive = false;
    address[] public loanPlanFormulas;
    mapping (address => Status) public loanPlanFormulaStatus;

    IDABFormula public formula;
    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;
    DABWalletFactory public walletFactory;
    ISmartToken public depositToken;
    ISmartToken public creditToken;
    ISmartToken public subCreditToken;
    ISmartToken public discreditToken;

    event LogActivation(uint256 _time);
    event LogFreezing(uint256 _time);
    event LogUpdateDABFormula(address _old, address _new);

/**
    @dev constructor

    @param _depositAgent DAB deposit agent contract
    @param _creditAgent DAB credit agent contract
    @param _startTime start time of the activation

*/
    constructor(
    DABDepositAgent _depositAgent,
    DABCreditAgent _creditAgent,
    uint256 _startTime)
    public
    validAddress(_depositAgent)
    validAddress(_creditAgent)
    DABOperationManager(_startTime)
    {
        depositAgent = _depositAgent;
        creditAgent = _creditAgent;

        formula = depositAgent.formula();

        depositToken = depositAgent.depositToken();
        creditToken = creditAgent.creditToken();
        subCreditToken = creditAgent.subCreditToken();
        discreditToken = creditAgent.discreditToken();
    }

// verifies that contract is active
    modifier active() {
        assert(isActive == true);
        _;
    }

// verifies that contract is inactive
    modifier inactive() {
        assert(isActive == false);
        _;
    }

/**
    @dev allows transferring the token agent ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDepositAgentOwnership(address _newOwner)
    public
    ownerOnly
    inactive 
    {
        depositAgent.transferOwnership(_newOwner);
    }

/**
    @dev allows accepting the token agent ownership
    can only be called by the contract owner

*/
    function acceptDepositAgentOwnership()
    public
    ownerOnly 
    {
        depositAgent.acceptOwnership();
    }

/**
    @dev allows transferring the token agent ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferCreditAgentOwnership(address _newOwner)
    public
    ownerOnly
    inactive 
    {
        creditAgent.transferOwnership(_newOwner);
    }

/**
    @dev allows accepting the token agent ownership
    can only be called by the contract owner

*/
    function acceptCreditAgentOwnership()
    public
    ownerOnly 
    {
        creditAgent.acceptOwnership();
    }

/**
    @dev allows transferring the token agent ownership
    the new owner still need to accept the transfer
    can only be called by the contract owner

    @param _newOwner    new token owner
*/
    function transferDABWalletFactoryOwnership(address _newOwner)
    public
    ownerOnly
    inactive 
    {
        walletFactory.transferOwnership(_newOwner);
    }

/**
    @dev allows accepting the wallet factory ownership
    can only be called by the contract owner

*/
    function acceptDABWalletFactoryOwnership()
    public
    ownerOnly 
    {
        walletFactory.acceptOwnership();
    }

/**
    @dev activate the contract
    can only be called by the contract owner

*/
    function activate()
    public
    ownerOnly 
    {
        depositAgent.activate();
        creditAgent.activate();
        walletFactory.activate();
        isActive = true;
        emit LogActivation(now);
    }

/**
    @dev freeze the contract
    can only be called by the contract owner

*/
    function freeze()
    public
    ownerOnly 
    {
        depositAgent.freeze();
        creditAgent.freeze();
        walletFactory.freeze();
        isActive = false;
        emit LogFreezing(now);
    }

/*
    @dev allows the DAB update the wallet factory

    @param _walletFactory    address of wallet factory
*/
    function setDABWalletFactory(DABWalletFactory _walletFactory)
    public
    ownerOnly
    notThis(_walletFactory)
    validAddress(_walletFactory)
    {
        walletFactory = _walletFactory;
    }

/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a DAB formula contract
*/
    function setDABFormula(IDABFormula _formula)
    public
    ownerOnly
    notThis(_formula)
    validAddress(_formula)
    {
        depositAgent.setDABFormula(_formula);
        creditAgent.setDABFormula(_formula);
        emit LogUpdateDABFormula(formula, _formula);
    }

/**
    @dev adds a new loan plan formula
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan formula contract
*/
    function addLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    ownerOnly
    {
        walletFactory.addLoanPlanFormula(_loanPlanFormula);
        loanPlanFormulas.push(_loanPlanFormula);
        loanPlanFormulaStatus[_loanPlanFormula].isValid = true;
    }


/**
    @dev disable a loan plan formula
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/
    function disableLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    ownerOnly
    {
        walletFactory.disableLoanPlanFormula(_loanPlanFormula);
        loanPlanFormulaStatus[_loanPlanFormula].isValid = false;
    }

/**
    @dev deposit QTUM
*/
    function deposit()
    public
    payable
    active
    started
    validAmount(msg.value) 
    {
        if (now > depositAgentActivationTime) {
            assert(depositAgent.deposit.value(msg.value)(msg.sender, true));
        }else {
            assert(depositAgent.deposit.value(msg.value)(msg.sender, false));
        }

    }

/**
    @dev withdraw QTUM

    @param _dptAmount amount to withdraw (in deposit token)
*/
    function withdraw(uint256 _dptAmount)
    public
    active
    activeDepositAgent
    validAmount(_dptAmount) 
    {
        assert(depositAgent.withdraw(msg.sender, _dptAmount));
    }

/**
    @dev cash credit token

    @param _cdtAmount amount to cash (in credit token)
*/
    function cash(uint256 _cdtAmount)
    public
    active
    activeCreditAgent
    validAmount(_cdtAmount) 
    {
        assert(creditAgent.cash(msg.sender, _cdtAmount));
    }

/**
    @dev loan by credit token

    @param _cdtAmount amount to loan (in credit token)
*/
    function loan(uint256 _cdtAmount)
    public
    active
    activeCreditAgent
    validAmount(_cdtAmount)
    {
        DABWallet wallet = DABWallet(msg.sender);
        bool isFormulaValid = walletFactory.isWalletFormulaValid(wallet);
        require(isFormulaValid);
        assert(creditAgent.loan(wallet, _cdtAmount));
    }

/**
    @dev repay by QTUM

*/
    function repay()
    public
    payable
    active
    activeCreditAgent
    validAmount(msg.value)
    {
        assert(creditAgent.repay.value(msg.value)(msg.sender));
    }

/**
    @dev convert discredit token to credit token by paying the debt in QTUM

*/
    function toCreditToken()
    public
    payable
    active
    activeCreditAgent
    validAmount(msg.value)
    {
        assert(creditAgent.toCreditToken.value(msg.value)(msg.sender));
    }

/**
    @dev convert subCredit token to discredit token

    @param _sctAmount amount to convert (in subCredit token)
*/
    function toDiscreditToken(uint256 _sctAmount)
    public
    active
    activeCreditAgent
    validAmount(_sctAmount) 
    {
        assert(creditAgent.toDiscreditToken(msg.sender, _sctAmount));
    }

/**
    @dev fallback function

*/
    function() payable {
        deposit();
    }
}