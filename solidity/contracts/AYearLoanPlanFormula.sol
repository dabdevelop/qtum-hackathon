pragma solidity ^0.4.11;

import './LoanPlanFormula.sol';

/*
    A Year Loan Plan Formula

    Interest float from 6% to 24%
    Loan days: 365 days
    Exempt days: 20 days
*/
contract AYearLoanPlanFormula is LoanPlanFormula {

/**
    @dev constructor
*/
    function AYearLoanPlanFormula() {
        highRate = EtherToFloat(240000000000000000);  // 24%
        lowRate = EtherToFloat(60000000000000000);    // 6%
        loanDays = 1 years;
        exemptDays = 20 days;
    }

}
