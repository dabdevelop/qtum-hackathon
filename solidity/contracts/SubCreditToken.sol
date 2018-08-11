pragma solidity ^0.4.11;

import './SmartToken.sol';


/*
    Sub-Credit Token

    Represent the amount holders loaned from credit agent contract
*/
contract SubCreditToken is SmartToken {

/**
    @dev constructor

    @param _name       token name
    @param _symbol     token short symbol, 1-6 characters
    @param _decimals   for display purposes only
*/
    function SubCreditToken(string _name, string _symbol, uint8 _decimals)
    SmartToken(_name, _symbol, _decimals)
    {}
}
