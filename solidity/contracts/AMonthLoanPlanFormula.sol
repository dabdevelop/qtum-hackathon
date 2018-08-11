pragma solidity ^0.4.11;

import './LoanPlanFormula.sol';

/*
    A Month Loan Plan Formula

    Interest float from 0.5% to 2%
    Loan days: 30 days
    Exempt days: 10 days
*/
contract AMonthLoanPlanFormula is LoanPlanFormula {

/**
    @dev constructor
*/
    function AMonthLoanPlanFormula() {
        highRate = EtherToFloat(20000000000000000);  // 2%
        lowRate = EtherToFloat(5000000000000000);    // 0.5%
        loanDays = 30 days;
        exemptDays = 10 days;
    }
}
