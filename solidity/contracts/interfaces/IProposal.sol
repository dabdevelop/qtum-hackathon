pragma solidity ^0.4.11;

import './IOwned.sol';

contract IProposal is IOwned {

    function proposalContract() public constant returns (address proposalContract) {proposalContract;}

    function propose() public;

    function vote(address, uint256) public;

    function execute() public;

    function redeem() public;
}
