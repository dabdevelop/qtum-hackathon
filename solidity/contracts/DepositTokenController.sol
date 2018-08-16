pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

/*
    Deposit Token Controller

*/
contract DepositTokenController is SmartTokenController {

/**
    @dev constructor

    @param _token   deposit token
*/
    constructor(ISmartToken _token)
    public
    SmartTokenController(_token)
    {}
}
