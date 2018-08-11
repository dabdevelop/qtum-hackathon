pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './interfaces/ILoanPlanFormula.sol';
import './interfaces/IERC20Token.sol';
import './Owned.sol';
import './SafeMath.sol';
import './DAB.sol';
import './DABDepositAgent.sol';
import './DABCreditAgent.sol';

/*
    DABWallet v0.1

    The wallet of the DAB, provide user-friendly interfaces to users.
*/

contract DABWallet is Owned, SafeMath {
    uint256 public depositBalance;
    uint256 public creditBalance;
    uint256 public subCreditBalance;
    uint256 public discreditBalance;
    uint256 public maxApprove = 100000 ether;
    uint256 public earlyRepayTime;
    uint256 public repayStartTime;
    uint256 public repayEndTime;
    uint256 public interestRate;
    uint256 public loanDays;
    uint256 public exemptDays;
    uint256 public lastRenew;
    uint256 public timeToRenew;
    bool public needRenew;
    address public user;
    address public newUser = 0x0;

    DAB public dab;
    DABWalletFactory public walletFactory;
    DABDepositAgent public depositAgent;
    DABCreditAgent public creditAgent;
    ILoanPlanFormula public formula;
    ISmartToken public depositToken;
    ISmartToken public creditToken;
    ISmartToken public subCreditToken;
    ISmartToken public discreditToken;

    event LogUpdateWalletOwnership(address _oldUser, address _newUser);
    event LogUpdateLoanPlanFormula(address _oldFormula, address _newFormula);

/**
    @dev constructor

    @param _dab     the address of dab
    @param _user     the address of a _user
*/
    function DABWallet(
    DAB _dab,
    address _user)
    validAddress(_dab)
    validAddress(_user)
    {
        dab = _dab;
        user = _user;

        depositBalance = 0;
        creditBalance = 0;
        subCreditBalance = 0;
        discreditBalance = 0;
        needRenew = true;
        formula = ILoanPlanFormula(0x0);

        walletFactory = dab.walletFactory();
        depositAgent = dab.depositAgent();
        creditAgent = dab.creditAgent();
        depositToken = dab.depositToken();
        creditToken = dab.creditToken();
        subCreditToken = dab.subCreditToken();
        discreditToken = dab.discreditToken();
    }

// ensures that the time the user repay is between repayStartTime (inclusive) and repayEndTime (inclusive)
    modifier repayBetween(){
        require(now >= earlyRepayTime && now <= repayEndTime);
        _;
    }

// verifies that an amount is greater than zero
    modifier validAmount(uint256 _amount){
        require(_amount > 0);
        _;
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address){
        require(_address != 0x0);
        _;
    }

// verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

// verifies that the wallet is renewable: the user repay or discredit all the sub-credit token
    modifier renewable(){
        uint256 balanceOfSCT = subCreditToken.balanceOf(this);
        require(balanceOfSCT == 0);
        _;
    }

// verifies that the msg sender is the user
    modifier userOnly(){
        require(msg.sender == user);
        _;
    }

// verifies that the address is the user
    modifier validUser(address _user){
        require(_user == user);
        _;
    }

// verifies that the loan is new
    modifier newLoan(){
        require(now < timeToRenew && needRenew == false);
        _;
    }

/**
    @dev deposit ETH

*/
    function depositETH()
    public
    payable
    validAmount(msg.value)
    {}

/**
    @dev withdraw ETH
    only called by user

    @param _ethAmount         amount of ETH to withdraw
*/
    function withdrawETH(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount)
    {
        transferETH(msg.sender, _ethAmount);
    }

/**
    @dev transfer ETH
    only called by user

    @param _ethAmount         amount of ETH to transfer
*/
    function transferETH(address _address, uint256 _ethAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_ethAmount)
    {
        _address.transfer(_ethAmount);
    }

/**
    @dev withdraw deposit token
    only called by user

    @param _dptAmount         amount of deposit token to withdraw
*/
    function withdrawDepositToken(uint256 _dptAmount)
    public
    userOnly
    validAmount(_dptAmount)
    {
        transferDepositToken(msg.sender, _dptAmount);
    }

/**
    @dev transfer deposit token
    only called by user

    @param _dptAmount         amount of deposit token to transfer
*/
    function transferDepositToken(address _address, uint256 _dptAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_dptAmount)
    {
        depositBalance = safeSub(depositBalance, _dptAmount);
        assert(depositToken.transfer(_address, _dptAmount));
    }

/**
    @dev withdraw credit token
    only called by user

    @param _cdtAmount         amount of credit token to withdraw
*/
    function withdrawCreditToken(uint256 _cdtAmount)
    public
    userOnly
    validAmount(_cdtAmount)
    {
        transferCreditToken(msg.sender, _cdtAmount);
    }

/**
    @dev transfer credit token
    only called by user

    @param _cdtAmount         amount of credit token to transfer
*/
    function transferCreditToken(address _address, uint256 _cdtAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_cdtAmount)
    {
        creditBalance = safeSub(creditBalance, _cdtAmount);
        assert(creditToken.transfer(_address, _cdtAmount));
    }

/**
    @dev withdraw discredit token
    only called by user

    @param _dctAmount         amount of discredit token to withdraw
*/
    function withdrawDiscreditToken(uint256 _dctAmount)
    public
    userOnly
    validAmount(_dctAmount)
    {
        transferDiscreditToken(msg.sender, _dctAmount);
    }

/**
    @dev transfer discredit token
    only called by user

    @param _dctAmount         amount of discredit token to transfer
*/
    function transferDiscreditToken(address _address, uint256 _dctAmount)
    public
    userOnly
    validAddress(_address)
    validAmount(_dctAmount)
    {
        discreditBalance = safeSub(discreditBalance, _dctAmount);
        assert(discreditToken.transfer(_address, _dctAmount));
    }

/**
    @dev withdraw any ERC20 token
    only called by user

    @param _token         token address
    @param _to         address transferred to
    @param _amount         amount of token to transfer
*/
    function transferTokens(IERC20Token _token, address _to, uint256 _amount)
    public
    userOnly
    validAddress(_token)
    validAddress(_to)
    notThis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }

/**
    @dev deposit ETH to DAB
    only called by user

    @param _ethAmount         ETH amount to deposit
*/
    function deposit(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount)
    {
        dab.deposit.value(_ethAmount)();
        updateWallet();
    }

/**
    @dev withdraw ETH from DAB
    only called by user

    @param _dptAmount         amount of deposit token to withdraw
*/
    function withdraw(uint256 _dptAmount)
    public
    userOnly
    validAmount(_dptAmount)
    {
        depositBalance = safeSub(depositBalance, _dptAmount);
        dab.withdraw(_dptAmount);
        updateWallet();
    }

/**
    @dev cash credit token from DAB
    only called by user

    @param _cdtAmount         amount of credit token to cash
*/
    function cash(uint256 _cdtAmount)
    public
    userOnly
    validAmount(_cdtAmount)
    {
        creditBalance = safeSub(creditBalance, _cdtAmount);
        dab.cash(_cdtAmount);
        updateWallet();
    }

/**
    @dev renew the loan plan of the wallet
    only called by user

*/
    function renewLoanPlan()
    public
    userOnly
    renewable
    {
        uint256 cdtSupply = creditToken.totalSupply();
        uint256 sctSupply = subCreditToken.totalSupply();
        var (_interestRate, _loanDays, _exemptDays) = formula.getLoanPlan(safeAdd(cdtSupply, sctSupply), cdtSupply);
        interestRate = _interestRate;
        loanDays = _loanDays;
        exemptDays = _exemptDays;
        needRenew = false;
        lastRenew = now;
        timeToRenew = lastRenew + 1 days;
    }

/**
    @dev loan from DAB
    only called by user

    @param _cdtAmount         amount of credit token used to loan
*/
    function loan(uint256 _cdtAmount)
    public
    userOnly
    newLoan
    validAmount(_cdtAmount)
    {
        needRenew = true;
        timeToRenew = now;
        repayStartTime = safeAdd(now, loanDays);
        repayEndTime = safeAdd(repayStartTime, exemptDays);
        earlyRepayTime = now + 1 weeks;
        if (earlyRepayTime > repayStartTime) {
            earlyRepayTime = repayStartTime;
        }

        require(_cdtAmount <= creditBalance);

        dab.loan(_cdtAmount);
        updateWallet();
    }

/**
    @dev repay to DAB
    only called by user

    @param _ethAmount         amount of ETH used to repay
*/
    function repay(uint256 _ethAmount)
    public
    userOnly
    repayBetween
    validAmount(_ethAmount) 
    {
        dab.repay.value(_ethAmount)();
        updateWallet();
    }

/**
    @dev discredit to DAB
    only called by user

    @param _sctAmount         amount of sub-credit token used to be discredit
*/
    function toDiscreditToken(uint256 _sctAmount)
    public
    userOnly
    validAmount(_sctAmount) 
    {
        subCreditBalance = safeSub(subCreditBalance, _sctAmount);
        dab.toDiscreditToken(_sctAmount);
        updateWallet();
    }

/**
    @dev credit to DAB
    only called by user

    @param _ethAmount         amount of ETH used to credit
*/
    function toCreditToken(uint256 _ethAmount)
    public
    userOnly
    validAmount(_ethAmount)
    {
        dab.toCreditToken.value(_ethAmount)();
        updateWallet();
    }

/**
    @dev transfer wallet's ownership
    only called by user

    @param _newUser         address of the new user
*/
    function transferWalletOwnership(address _newUser)
    public
    userOnly
    validAddress(_newUser)
    {
        require(_newUser != user);
        newUser = _newUser;
    }

/**
    @dev accept a wallet ownership
    only called by new user

*/
    function acceptWalletOwnership()
    public 
    {
        require(msg.sender == newUser);
        address oldUser = user;
        user = newUser;
        newUser = 0x0;
        LogUpdateWalletOwnership(oldUser, user);
    }

/**
    @dev set default loan plan formula for the wallet
    only called by owner, the wallet factory

    @param _formula         address of a new formula
*/
    function setLoanPlanFormula(ILoanPlanFormula _formula)
    public
    ownerOnly
    validAddress(_formula) 
    {
        require(_formula != formula);
        address oldFormula = formula;
        formula = _formula;
        needRenew = true;
        LogUpdateLoanPlanFormula(oldFormula, formula);
    }

/**
    @dev approve the credit agent and deposit agent to have access to the wallet's funds.
    only called by user

*/
    function approve(uint256 _approveAmount)
    public
    userOnly 
    {
        require(_approveAmount >= 0);
        depositToken.approve(depositAgent, 0);
        creditToken.approve(creditAgent, 0);
        subCreditToken.approve(creditAgent, 0);
        discreditToken.approve(creditAgent, 0);
        if (_approveAmount != 0) {
            depositToken.approve(depositAgent, _approveAmount);
            creditToken.approve(creditAgent, _approveAmount);
            subCreditToken.approve(creditAgent, _approveAmount);
            discreditToken.approve(creditAgent, _approveAmount);
        }
    }

/**
    @dev approve the credit agent and deposit agent to have access to the wallet's funds.
    only called by user

*/
    function approveMax()
    public
    userOnly 
    {
        approve(maxApprove);
    }

/**
@dev set DAB wallet with a loan plan formula

*/
    function setWalletLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    userOnly 
    {
        walletFactory.setWalletLoanPlanFormula(_loanPlanFormula);
    }

/**
    @dev update the wallet's funds, for the wallet cannot automatically get the incoming ERC20 tokens.
    only called by user

*/
    function updateWallet()
    public
    userOnly 
    {
        depositBalance = depositToken.balanceOf(this);
        creditBalance = creditToken.balanceOf(this);
        subCreditBalance = subCreditToken.balanceOf(this);
        discreditBalance = discreditToken.balanceOf(this);
        if (subCreditBalance == 0 && now > safeAdd(lastRenew, timeToRenew)) {
            needRenew = true;
        }
    }

/**
    @dev fallback
*/
    function() payable {
        depositETH();
    }
}


/*
    DABWalletFactory v0.1

    The wallet factory of the DAB, generate user-friendly wallet to users.
*/
contract DABWalletFactory is Owned {

    struct LoanPlanFormula {
        bool isValid;
    }

    struct Wallet {
        address loanPlanFormula;
        bool isValid;
    }

    bool public isActive = false;
    uint256 public walletCount = 0;
    address[] public loanPlanFormulasList;
    mapping (address => LoanPlanFormula) public loanPlanFormulas;
    mapping (address => Wallet) public wallets;

    DAB public dab;

    event LogAddLoanPlanFormula(address _formula);
    event LogDisableLoanPlanFormula(address _formula);
    event LogNewWallet(address _user, address _wallet);

/**
    @dev constructor

    @param _dab     the address of dab
*/
    function DABWalletFactory(DAB _dab)
    validAddress(_dab)
    {
        dab = _dab;

        loanPlanFormulas[0x0].isValid = false;
    }

    // verifies that an amount is greater than zero
    modifier active() {
        require(isActive == true);
        _;
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

// verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

// validates a loan plan formula
    modifier validLoanPlanFormula(address _formula) {
        require(loanPlanFormulas[_formula].isValid);
        _;
    }

// validates a DAB wallet
    modifier validWallet(address _wallet) {
        require(wallets[_wallet].isValid);
        _;
    }

// validates a DAB wallet's formula
    modifier validWalletFormula(address _wallet) {
        require(loanPlanFormulas[wallets[_wallet].loanPlanFormula].isValid);
        _;
    }

// activate the DAB wallet factory
    function activate()
    public
    ownerOnly
    {
        isActive = true;
    }

// freeze the DAB wallet factory
    function freeze()
    public
    ownerOnly
    {
        isActive = false;
    }

/**
    @dev defines a new loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/
    function addLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    ownerOnly
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    {
        require(!loanPlanFormulas[_loanPlanFormula].isValid); // validate input
        loanPlanFormulasList.push(_loanPlanFormula);
        loanPlanFormulas[_loanPlanFormula].isValid = true;
        LogAddLoanPlanFormula(_loanPlanFormula);
    }


/**
    @dev disable a loan plan
    can only be called by the owner

    @param _loanPlanFormula         address of the loan plan
*/
    function disableLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    ownerOnly
    validAddress(_loanPlanFormula)
    notThis(_loanPlanFormula)
    validLoanPlanFormula(_loanPlanFormula)
    {
        loanPlanFormulas[_loanPlanFormula].isValid = false;
        LogDisableLoanPlanFormula(_loanPlanFormula);
    }

/**
@dev create a new DAB wallet with a loan plan

*/
    function newDABWallet()
    public
    payable 
    {
        address wallet = new DABWallet(dab, msg.sender);
        if (msg.value > 0) {
            wallet.transfer(msg.value);
        }
        wallets[wallet].isValid = true;
        wallets[wallet].loanPlanFormula = ILoanPlanFormula(0x0);
        walletCount = walletCount + 1;
        LogNewWallet(msg.sender, wallet);
    }

/**
@dev set DAB wallet with a loan plan formula

*/
    function setWalletLoanPlanFormula(ILoanPlanFormula _loanPlanFormula)
    public
    validWallet(msg.sender)
    validLoanPlanFormula(_loanPlanFormula)
    {
        DABWallet wallet = DABWallet(msg.sender);
        wallet.setLoanPlanFormula(_loanPlanFormula);
        wallets[wallet].loanPlanFormula = _loanPlanFormula;
    }

/**
    @dev check the validation of a wallet

    @param _wallet         address of the wallet

    @return validation status of the wallet
*/
    function isWalletFormulaValid(DABWallet _wallet)
    public
    active
    validWallet(_wallet)
    returns (bool)
    {
        return loanPlanFormulas[wallets[_wallet].loanPlanFormula].isValid;
    }

}

