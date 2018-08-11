pragma solidity ^0.4.11;

import './IOwned.sol';
import './IProposal.sol';
import './ISmartToken.sol';
import './IDABFormula.sol';
import './ILoanPlanFormula.sol';

contract IDAB is IOwned {

    function depositAgent() public constant returns (address depositAgent) {depositAgent;}

    function depositToken() public constant returns (ISmartToken depositToken) {depositToken;}

    function setDABFormula(IDABFormula formula) public;

    function addLoanPlanFormula(ILoanPlanFormula formula) public;

    function disableLoanPlanFormula(ILoanPlanFormula formula) public;

}
