pragma solidity ^0.4.11;

import './interfaces/ISmartToken.sol';
import './SmartTokenController.sol';

contract VoteTokenController is SmartTokenController {
    function VoteTokenController(ISmartToken _token)
    SmartTokenController(_token) 
    {}
}
