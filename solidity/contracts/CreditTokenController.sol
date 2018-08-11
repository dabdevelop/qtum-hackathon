pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

/*
    Credit Token Controller

*/
contract CreditTokenController is SmartTokenController {

/**
    @dev constructor

    @param _token   credit token
*/
    function CreditTokenController(ISmartToken _token)
    SmartTokenController(_token) 
    {}
}
