pragma solidity ^0.4.11;


import './interfaces/IDABFormula.sol';
import './Math.sol';


/*
    Implementation of CRR Formula v0.1
    a,b,l,d controls the curve of CRR

    This formula is approximate calculation, not absolute precise
*/

contract EasyDABFormula is IDABFormula, Math {
    string public version = "0.1";
    uint256 public a = EtherToFloat(600000000000000000);                // a = 0.6
    uint256 public b = EtherToFloat(200000000000000000);                // b = 0.2
    uint256 public l = Float(30000000);                                 // l = 30000000
    uint256 public d = l / 4;                                           // d = l/4
    uint256 public ip = EtherToFloat(10000000000000000);                // dpt_ip = 0.01  initial price of deposit token
    uint256 public cdt_ip = ip * 2;                                     // cdt_ip = 0.02  initial price of credit token
    uint256 public cdt_crr = Float(3);                                  // cdt_crr = 3
    uint256 public cdtCashFeeRate = EtherToFloat(100000000000000000);   // fee rate = 0.1
    uint256 public cdtLoanRate = ip;                                    // credit token to ether ratio
    uint256 public cdtReserveRate = EtherToFloat(500000000000000000);   // credit token reserve = 0.5, credit token reserve the rate of interest to expand itself
    uint256 public sctToDCTRate = EtherToFloat(800000000000000000);     // subCredit token to discredit token ratio = 0.8
    uint256 public maxETH = mul(div(l, Float(1000)), ip);               // max ETH deposit to meet the formula accuracy
    uint256 public maxDPT = mul(div(l, Float(1000)), b);                // max DPT withdraw to meet the formula accuracy

/*
    @dev get cash reserve ratio of deposit token according to circulation of deposit token

    @param _dptCirculation circulation of deposit token

    @return cash reserve ratio of deposit token
*/
    function getCRR(uint256 _dptCirculation)
    private
    returns (uint256)
    {
        return sigmoid(a, b, l, d, _dptCirculation);
    }

/*
    @dev calculate the issue amount

    @param _dptCirculation circulation of deposit token
    @param _ethAmount eth amount to deposit

    @return deposit token issued to user
    @return credit token issued to user
    @return deposit token issued to founder
    @return credit token issued to founder
*/
    function issue(uint256 _dptCirculation, uint256 _ethAmount)
    public
    constant
    returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        _dptCirculation = EtherToFloat(_dptCirculation);
        _ethAmount = EtherToFloat(_ethAmount);

        require(_dptCirculation >= 0);
        require(_ethAmount > 0);

        uint256 fCRR = getCRR(_dptCirculation);
        uint256 ethDeposit = mul(_ethAmount, fCRR);
        uint256 fDPT = div(ethDeposit, ip);
        uint256 fCDT = div(mul(sub(FLOAT_ONE, fCRR), _ethAmount), cdt_ip);
        _dptCirculation = add(_dptCirculation, fDPT);
        fCRR = getCRR(_dptCirculation);
        uint256 F = div(sub(FLOAT_ONE, fCRR), Float(2));
        uint256 U = sub(FLOAT_ONE, F);
        return (FloatToEther(mul(fDPT, U)), FloatToEther(mul(fCDT, U)), FloatToEther(mul(fDPT, F)), FloatToEther(mul(fCDT, F)), FloatToEther(ethDeposit), FloatToDecimal(fCRR));
    }

/*
    @dev calculate the deposit amount

    @param _ethBalance eth balance of deposit agent contract
    @param _dptSupply total supply of deposit token
    @param _dptCirculation circulation of deposit token
    @param _ethAmount eth amount to deposit

    @return dptAmount deposit token amount
    @return ethRemain eth remain to issue
    @return dCRR cash reserve ratio of deposit token
    @return dptPrice price of deposit token after deposit
*/
    function deposit(uint256 _ethBalance, uint256 _dptSupply, uint256 _dptCirculation, uint256 _ethAmount)
    public
    constant
    returns (uint256 dptAmount, uint256 ethRemain, uint256 dCRR, uint256 dptPrice)
    {
        _ethBalance = EtherToFloat(_ethBalance);
        _dptSupply = EtherToFloat(_dptSupply);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _ethAmount = EtherToFloat(_ethAmount);

        require(_ethBalance >= 0);
        require(_dptSupply >= 0);
        require(_dptCirculation >= 0 && _dptCirculation <= _dptSupply);
        require(_ethAmount > 0);
    // ensure the accuracy of the formula
        require(_ethAmount <= maxETH);

        uint256 fCRR = getCRR(_dptCirculation);
        dptPrice = div(_ethBalance, mul(_dptCirculation, fCRR));
        dptAmount = div(_ethAmount, dptPrice);
        uint256 maxBalance = add(_ethBalance, _ethAmount);
        fCRR = getCRR(add(_dptCirculation, dptAmount));
        dptPrice = div(maxBalance, mul(_dptCirculation, fCRR));
        dptAmount = div(_ethAmount, dptPrice);

        if (sub(_dptSupply, _dptCirculation) >= dptAmount) {
            fCRR = getCRR(add(_dptCirculation, dptAmount));
            dptPrice = div(maxBalance, mul(add(_dptCirculation, dptAmount), fCRR));
            return (FloatToEther(dptAmount), 0, FloatToDecimal(fCRR), FloatToDecimal(dptPrice));
        } else {
            dptAmount = sub(_dptSupply, _dptCirculation);
            fCRR = getCRR(add(_dptCirculation, dptAmount));
            dptPrice = div(maxBalance, mul(_dptCirculation, fCRR));
            return (FloatToEther(dptAmount), FloatToEther(sub(_ethAmount, mul(dptAmount, dptPrice))), FloatToDecimal(fCRR), FloatToDecimal(dptPrice));

        }
    }

/*
    @dev calculate the withdraw amount

    @param _ethBalance eth balance of deposit agent contract
    @param _dptCirculation circulation of deposit token
    @param _dptAmount deposit token amount to withdraw

    @return ethAmount eth amount withdrawn to user
    @return dCRR cash reserve ratio of deposit token
    @return dptPrice price of deposit token after withdraw
*/
    function withdraw(uint256 _ethBalance, uint256 _dptCirculation, uint256 _dptAmount)
    public
    constant
    returns (uint256 ethAmount, uint256 dCRR, uint256 dptPrice)
    {
        _ethBalance = EtherToFloat(_ethBalance);
        _dptCirculation = EtherToFloat(_dptCirculation);
        _dptAmount = EtherToFloat(_dptAmount);

        require(_ethBalance > 0 );
        require(_dptCirculation > 0);
        require(_dptAmount > 0);
    // ensure the accuracy of the formula
        require(_dptAmount <= maxDPT);

        dptPrice = div(_ethBalance, mul(_dptCirculation, getCRR(_dptCirculation)));
        ethAmount = mul(_dptAmount, dptPrice);

        uint256 fCRR = getCRR(sub(_dptCirculation, _dptAmount));
        dptPrice = div(sub(_ethBalance, ethAmount), mul(_dptCirculation, fCRR));
        uint256 actualEther = mul(_dptAmount, dptPrice);
        return (FloatToEther(actualEther), FloatToDecimal(fCRR), FloatToDecimal(dptPrice));
    }

/*
    @dev calculate the cash amount

    @param _ethBalance eth balance of credit agent contract
    @param _cdtSupply total supply of credit token
    @param _cdtAmount credit token amount to cash

    @return ethAmount eth amount cashed to user
    @return cdtPrice price of credit token after withdraw
*/
    function cash(uint256 _ethBalance, uint256 _cdtSupply, uint256 _cdtAmount)
    public
    constant
    returns (uint256 ethAmount, uint256 cdtPrice)
    {
        _ethBalance = EtherToFloat(_ethBalance);
        _cdtSupply = EtherToFloat(_cdtSupply);
        _cdtAmount = EtherToFloat(_cdtAmount);

        require(_ethBalance > 0);
        require(_cdtSupply > 0);
        require(_cdtAmount > 0);

        cdtPrice = div(_ethBalance, mul(_cdtSupply, cdt_crr));
        ethAmount = mul(_cdtAmount, cdtPrice);

        require(ethAmount <= _ethBalance);

        uint256 cashFee = mul(ethAmount, cdtCashFeeRate);
        ethAmount = sub(ethAmount, cashFee);
        _ethBalance = sub(_ethBalance, ethAmount);
        cdtPrice = div(_ethBalance, mul(_cdtSupply, cdt_crr));

        return (FloatToEther(ethAmount), FloatToDecimal(cdtPrice));
    }

/*
    @dev calculate the loan amount

    @param _cdtAmount credit token amount to cash
    @param _interestRate interest rate

    @return ethAmount eth amount loaned to user
    @return ethInterest interest user paid
    @return cdtIssuanceAmount credit token issued to user
    @return sctAmount sub-credit token issued to user
*/
    function loan(uint256 _cdtAmount, uint256 _interestRate, uint256 _dptCRR)
    public
    constant
    returns (uint256 ethAmount, uint256 ethInterest, uint256 cdtIssuanceAmount, uint256 sctAmount)
    {
        _cdtAmount = EtherToFloat(_cdtAmount);
        _interestRate = DecimalToFloat(_interestRate);
        _dptCRR = DecimalToFloat(_dptCRR);

        require(_cdtAmount > 0);
        require(_interestRate > 0);
        require(_interestRate < Float(1));
        require(_dptCRR > 0);
        require(_dptCRR < Float(1));

        ethAmount = mul(_cdtAmount, cdtLoanRate);
        uint256 interest = mul(ethAmount, _interestRate);
        uint256 cdtReserve = mul(interest, cdtReserveRate);
        ethInterest = sub(interest, cdtReserve);
        cdtIssuanceAmount = div(mul(interest, _dptCRR), cdt_ip);
        ethAmount = sub(ethAmount, interest);
        sctAmount = _cdtAmount;

        return (FloatToEther(ethAmount), FloatToEther(ethInterest), FloatToEther(cdtIssuanceAmount), FloatToEther(sctAmount));
    }

/*
    @dev calculate the repay amount

    @param _ethRepayAmount eth amount the user repay
    @param _sctAmount sub-credit amount of the user

    @return ethRefundAmount eth amount refund to the user
    @return cdtAmount credit amount redeemed to the user
    @return sctRefundAmount sub-credit token refund to the user
*/
    function repay(uint256 _ethRepayAmount, uint256 _sctAmount)
    public
    constant
    returns (uint256 ethRefundAmount, uint256 cdtAmount, uint256 sctRefundAmount)
    {
        _ethRepayAmount = EtherToFloat(_ethRepayAmount);
        _sctAmount = EtherToFloat(_sctAmount);

        require(_ethRepayAmount > 0);
        require(_sctAmount > 0);

        uint256 ethAmount = mul(_sctAmount, cdtLoanRate);
        if (_ethRepayAmount < ethAmount) {
            ethAmount = _ethRepayAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            sctRefundAmount = sub(_sctAmount, cdtAmount);
            return (0, FloatToEther(cdtAmount), FloatToEther(sctRefundAmount));
        } else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            ethRefundAmount = sub(_ethRepayAmount, ethAmount);
            return (FloatToEther(ethRefundAmount), FloatToEther(cdtAmount), 0);
        }
    }



/*
    @dev calculate the amount of conversion from discredit token to credit token

    @param _ethCreditAmount eth amount the user to credit
    @param _dctAmount discredit amount of the user

    @return ethRefundAmount eth amount refund to the user
    @return cdtAmount credit amount redeemed to the user
    @return dctRefundAmount discredit token refund to the user
*/
    function toCreditToken(uint256 _ethCreditAmount, uint256 _dctAmount)
    public
    constant
    returns (uint256 ethRefundAmount, uint256 cdtAmount, uint256 dctRefundAmount)
    {
        _ethCreditAmount = EtherToFloat(_ethCreditAmount);
        _dctAmount = EtherToFloat(_dctAmount);

        require(_ethCreditAmount > 0);
        require(_dctAmount > 0);

        uint256 ethAmount = mul(_dctAmount, cdtLoanRate);
        if (_ethCreditAmount < ethAmount) {
            ethAmount = _ethCreditAmount;
            cdtAmount = div(ethAmount, cdtLoanRate);
            dctRefundAmount = sub(_dctAmount, cdtAmount);
            return (0, FloatToEther(cdtAmount), FloatToEther(dctRefundAmount));
        } else {
            cdtAmount = div(ethAmount, cdtLoanRate);
            ethRefundAmount = sub(_ethCreditAmount, ethAmount);
            return (FloatToEther(ethRefundAmount), FloatToEther(cdtAmount), 0);
        }
    }


/*
    @dev calculate the amount of conversion from sub-credit token to discredit token

    @param _ethBalance eth balance the credit agent contract
    @param _cdtSupply total supply of credit token
    @param _sctAmount sub-credit token amount of the user

    @return dctAmount discredit token amount to the user
    @return cdtPrice price of credit token after the conversion
*/
    function toDiscreditToken(uint256 _ethBalance, uint256 _cdtSupply, uint256 _sctAmount)
    public
    constant
    returns (uint256 dctAmount, uint256 cdtPrice)
    {
        _ethBalance = EtherToFloat(_ethBalance);
        _cdtSupply = EtherToFloat(_cdtSupply);
        _sctAmount = EtherToFloat(_sctAmount);

        require(_ethBalance > 0);
        require(_cdtSupply > 0);
        require(_sctAmount > 0);

        cdtPrice = div(_ethBalance, mul(_cdtSupply, cdt_crr));

        return (FloatToEther(mul(_sctAmount, sctToDCTRate)), FloatToDecimal(cdtPrice));
    }


}