pragma solidity ^0.4.11;

import './LoanPlanFormula.sol';

/*
    A Month Loan Plan Formula

    Interest float from 12% to 48%
    Loan days: 730 days
    Exempt days: 25 days
*/
contract TwoYearLoanPlanFormula is LoanPlanFormula {

/**
    @dev constructor
*/
    constructor() public {
        highRate = EtherToFloat(480000000000000000);   // 48%
        lowRate = EtherToFloat(120000000000000000);    // 12%
        loanDays = 730 days;
        exemptDays = 25 days;
    }

}
