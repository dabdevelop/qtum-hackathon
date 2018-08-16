#!/bin/bash

# json parser need to pre-install jq https://github.com/stedolan/jq
# solc should use option `--evm-version homestead `

# export QTUM_SENDER=qLciaCb19kqqaPVeEQyjjViVBqpJdVvRkx
export QTUM_SENDER=qeDKhVC2rqpWQpwty52UsE9Nsi1jUarsyJ
export QTUM_RPC=http://qtum:test@localhost:3889
export GAS_LIMIT=40000000

SOURCE_DIR=solidity/contracts

echo deploy $SOURCE_DIR/AMonthLoanPlanFormula.sol
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/AMonthLoanPlanFormula.sol
echo deploy $SOURCE_DIR/HalfAYearLoanPlanFormula.sol
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/HalfAYearLoanPlanFormula.sol
echo deploy $SOURCE_DIR/AYearLoanPlanFormula.sol
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/AYearLoanPlanFormula.sol
echo deploy $SOURCE_DIR/TwoYearLoanPlanFormula.sol
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/TwoYearLoanPlanFormula.sol

echo deploy $SOURCE_DIR/EasyDABFormula.sol
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/EasyDABFormula.sol

echo deploy $SOURCE_DIR/DepositToken.sol '["Deposit Token", "DPT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DepositToken.sol '["Deposit Token", "DPT", 18]'
echo deploy $SOURCE_DIR/CreditToken.sol '["Credit Token", "CDT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/CreditToken.sol '["Credit Token", "CDT", 18]'
echo deploy $SOURCE_DIR/SubCreditToken.sol '["SubCredit Token", "SCT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/SubCreditToken.sol '["SubCredit Token", "SCT", 18]'
echo deploy $SOURCE_DIR/DiscreditToken.sol '["Discredit Token", "DCT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DiscreditToken.sol '["Discredit Token", "DCT", 18]'

DepositTokenAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DepositToken.sol".address'`
CreditTokenAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/CreditToken.sol".address'`
SubCreditTokenAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/SubCreditToken.sol".address'`
DiscreditTokenAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DiscreditToken.sol".address'`

echo deploy $SOURCE_DIR/DepositTokenController.sol '['$DepositTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DepositTokenController.sol '['$DepositTokenAddress']'
echo deploy $SOURCE_DIR/CreditTokenController.sol '['$CreditTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/CreditTokenController.sol '['$CreditTokenAddress']'
echo deploy $SOURCE_DIR/SubCreditTokenController.sol '['$SubCreditTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/SubCreditTokenController.sol '['$SubCreditTokenAddress']'
echo deploy $SOURCE_DIR/DiscreditTokenController.sol '['$DiscreditTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DiscreditTokenController.sol '['$DiscreditTokenAddress']'

EasyDABFormulaAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/EasyDABFormula.sol".address'`

DepositTokenControllerAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DepositTokenController.sol".address'`
CreditTokenControllerAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/CreditTokenController.sol".address'`
SubCreditTokenControllerAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/SubCreditTokenController.sol".address'`
DiscreditTokenControllerAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DiscreditTokenController.sol".address'`

BeneficiaryAddress=0xe28f6f97eb10fcb9b0edcf3a96e147f6fada72a7

echo deploy $SOURCE_DIR/DABCreditAgent.sol '['$EasyDABFormulaAddress', '$CreditTokenControllerAddress', '$SubCreditTokenControllerAddress', '$DiscreditTokenControllerAddress', "'$BeneficiaryAddress'"]'

solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DABCreditAgent.sol '['$EasyDABFormulaAddress', '$CreditTokenControllerAddress', '$SubCreditTokenControllerAddress', '$DiscreditTokenControllerAddress', "'$BeneficiaryAddress'"]'

DABCreditAgentAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DABCreditAgent.sol".address'`

echo deploy $SOURCE_DIR/DABDepositAgent.sol '['$DiscreditTokenAddress', '$EasyDABFormulaAddress', '$DepositTokenControllerAddress', "'$BeneficiaryAddress'"]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DABDepositAgent.sol '['$DiscreditTokenAddress', '$EasyDABFormulaAddress', '$DepositTokenControllerAddress', "'$BeneficiaryAddress'"]'

DABDepositAgentAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DABDepositAgent.sol".address'`

now=`date +%s`
startTime=`expr $now + 60`

echo deploy $SOURCE_DIR/DAB.sol '['$DABDepositAgentAddress', '$DABCreditAgentAddress', '$startTime']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DAB.sol '['$DABDepositAgentAddress', '$DABCreditAgentAddress', '$startTime']'

DABAddress=`cat solar.development.json |jq '.contracts."'$SOURCE_DIR'/DAB.sol".address'`

echo deploy $SOURCE_DIR/DABWalletFactory.sol '['$DABAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT $SOURCE_DIR/DABWalletFactory.sol '['$DABAddress']'





