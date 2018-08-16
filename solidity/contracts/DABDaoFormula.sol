pragma solidity ^0.4.11;

import './interfaces/IDABDaoFormula.sol';
import './Math.sol';

/*
    DABDaoFormula v0.1

    The formula of the DAB DAO, to calculate a proposal's support ratio
*/

contract DABDaoFormula is Math {

/**
    @dev constructor
*/
    constructor() public {}

/**
    @dev to verifies if the support rate is enough

    @param _circulation the circulation of deposit token
    @param _vote the vote of the proposal
    @param _threshold the threshold to execute the function

    @return the outcome of the proposal is approved or not
*/
    function isApproved(uint256 _circulation, uint256 _vote, uint256 _threshold) public constant returns (bool) {
        _circulation = EtherToFloat(_circulation);
        _vote = EtherToFloat(_vote);
        _threshold = div(Float(_threshold), Float(100));
        uint256 realRate = div(_vote, _circulation);
        if (realRate >= _threshold) {
            return true;
        } else {
            return false;
        }
    }
}
