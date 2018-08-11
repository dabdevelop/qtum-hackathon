pragma solidity ^0.4.11;

import './LoanPlanFormula.sol';

/*
    Half A Year Loan Plan Formula

    Interest float from 3% to 12%
    Loan days: 180 days
    Exempt days: 15 days
*/
contract HalfAYearLoanPlanFormula is LoanPlanFormula {

/**
    @dev constructor
*/
    function HalfAYearLoanPlanFormula() {
        highRate = EtherToFloat(120000000000000000);   // 12%
        lowRate = EtherToFloat(30000000000000000);     // 3%
        loanDays = 180 days;
        exemptDays = 15 days;
    }

}
