pragma solidity ^0.4.11;

/*
    Overflow protected math functions
*/
contract SafeMath {
/**
    constructor
*/
    constructor() public {
    }

/**
    @dev returns the sum of _x and _y, asserts if the calculation overflows

    @param _x   value 1
    @param _y   value 2

    @return sum
*/
    function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

/**
    @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

    @param _x   minuend
    @param _y   subtrahend

    @return difference
*/
    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

/**
    @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

    @param _x   factor 1
    @param _y   factor 2

    @return product
*/
    function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }

/**
    @dev returns the division of _x by _y, asserts if the calculation overflows

    @param _x   value 1
    @param _y   value 2

    @return division
*/
    function safeDiv(uint256 _x, uint256 _y) internal pure returns (uint256) {
        assert(_y > 0);
    // Solidity automatically throws when dividing by 0
        uint256 _z = _x / _y;
        assert(_x == _y * _z + _x % _y);
    // There is no case in which this doesn't hold
        return _z;
    }
}
