pragma solidity ^0.4.11;

import './interfaces/ILoanPlanFormula.sol';
import './Math.sol';

/*
    Loan Plan Formula
*/
contract LoanPlanFormula is ILoanPlanFormula, Math {

    uint256 public highRate;  // 2.5%
    uint256 public lowRate;    // 0.5%
    uint256 public loanDays;
    uint256 public exemptDays;
/**
    @dev constructor
*/
    constructor() public {}

/*
@dev get the loan plan according to loan days, credit token supply and circulation

@param _supply total supply of credit token
@param _circulation circulation of credit token
@return interest rate
@return loan days
@return exempt days
*/
    function getLoanPlan(uint256 _supply, uint256 _circulation)
    public view
    returns (uint256, uint256, uint256)
    {

        _supply = EtherToFloat(_supply);
        _circulation = EtherToFloat(_circulation);

        require(0 <= _supply);
        require(0 <= _circulation && _circulation <= _supply);

        return (FloatToDecimal(sigmoid(sub(highRate, lowRate), lowRate, _supply / 2, _supply / 8, _circulation)), loanDays, exemptDays);
    }

}
