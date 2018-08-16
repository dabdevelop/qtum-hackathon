pragma solidity ^0.4.11;

import './Owned.sol';
import './SafeMath.sol';
import './interfaces/IDABFormula.sol';

/*
    DABAgent v0.1

    The agent of the DAB
*/

contract DABAgent is Owned, SafeMath {

    struct Token {
    uint256 supply;                              // total supply = issue - destroy
    bool isValid;                                // used to tell if the mapping element is defined
    }

    string public version = "0.1";
    bool public isActive = false;                // agent is inactive when initiated
    uint256 public balance;                      // balance of the agent(in ETH)
    address public beneficiary = 0x0;            // address to receive founders share
    address[] public tokenSet;                   // token addresses set
    mapping (address => Token) public tokens;    // token addresses -> token data

    IDABFormula public formula;

/**
    @dev constructor

    @param _formula      DAB formula
    @param _beneficiary      beneficiary address
*/
    constructor(
    IDABFormula _formula,
    address _beneficiary)
    public
    validAddress(_formula)
    validAddress(_beneficiary)
    {
        formula = _formula;
        balance = 0;
        beneficiary = _beneficiary;
    }

// validates a token address - verifies that the address belongs to one of the changeable tokens
    modifier validToken(address _address) {
        require(tokens[_address].isValid);
        _;
    }

// verifies that an agent is active
    modifier active() {
        require(isActive == true);
        _;
    }

// verifies that an agent is inactive
    modifier inactive() {
        require(isActive == false);
        _;
    }

// verifies that an amount is greater than zero
    modifier validAmount(uint256 _amount) {
        require(_amount > 0);
        _;
    }

// validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

// verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

/*
    @dev allows the owner to update the formula contract address

    @param _formula    address of a DAB formula contract
*/
    function setDABFormula(IDABFormula _formula)
    public
    ownerOnly
    inactive
    notThis(_formula)
    validAddress(_formula)
    {
        require(_formula != formula);
        formula = _formula;
    }
}
