pragma solidity ^0.4.11;

import './SmartToken.sol';

/*
    Vote Token

    Represent the amount holders voted to a proposal
*/
contract VoteToken is SmartToken {

/**
    @dev constructor

    @param _name       token name
    @param _symbol     token short symbol, 1-6 characters
    @param _decimals   for display purposes only
*/
    function VoteToken(string _name, string _symbol, uint8 _decimals)
    SmartToken(_name, _symbol, _decimals)
    {}
}
