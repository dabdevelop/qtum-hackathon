pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

/*
    Sub-Credit Token Controller

*/
contract SubCreditTokenController is SmartTokenController {

/**
    @dev constructor

    @param _token   sub-credit token
*/
    function SubCreditTokenController(ISmartToken _token)
    SmartTokenController(_token)
    {}
}
