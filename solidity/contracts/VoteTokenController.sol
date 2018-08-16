pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

contract VoteTokenController is SmartTokenController {

    /**
    @dev constructor

    @param _token   vote token
    */
    constructor(ISmartToken _token)
    public
    SmartTokenController(_token) 
    {}
}
