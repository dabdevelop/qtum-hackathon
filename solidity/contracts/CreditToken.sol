pragma solidity ^0.4.11;

import './SmartToken.sol';


/*
    Credit Token

    Represent holders' share of funds in credit agent contract
*/
contract CreditToken is SmartToken {

/**
    @dev constructor

    @param _name       token name
    @param _symbol     token short symbol, 1-6 characters
    @param _decimals   for display purposes only
*/
    constructor(string _name, string _symbol, uint8 _decimals) 
    public
    SmartToken(_name, _symbol, _decimals) 
    {}
}
