pragma solidity ^0.4.11;

import '../LoanPlanFormula.sol';

/*
    Test Loan Plan Formula

    Interest float from 6% to 25%
    Loan days: 2 min
    Exempt days: 5 min
*/
contract TestLoanPlanFormula is LoanPlanFormula {

/**
    @dev constructor
*/
    function AYearLoanPlanFormula() {
        highRate = EtherToFloat(240000000000000000);  // 25%
        lowRate = EtherToFloat(60000000000000000);    // 6%
        loanDays = 120;
        exemptDays = 300;
    }

}
