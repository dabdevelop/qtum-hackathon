pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

/*
    Discredit Token Controller

*/
contract DiscreditTokenController is SmartTokenController {

/**
    @dev constructor

    @param _token   discredit token
*/
    constructor(ISmartToken _token)
    public
    SmartTokenController(_token) 
    {}
}
