#!/bin/bash

# use "solc --bin --asm --evm-version homestead"

export QTUM_SENDER=qeDKhVC2rqpWQpwty52UsE9Nsi1jUarsyJ
export QTUM_RPC=http://qtum:test@localhost:3889
export GAS_LIMIT=40000000

echo deploy contracts/EasyDABFormula.sol
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/EasyDABFormula.sol

echo deploy contracts/DepositToken.sol '["Deposit Token", "DPT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DepositToken.sol '["Deposit Token", "DPT", 18]'
echo deploy contracts/CreditToken.sol '["Credit Token", "CDT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/CreditToken.sol '["Credit Token", "CDT", 18]'
echo deploy contracts/SubCreditToken.sol '["SubCredit Token", "SCT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/SubCreditToken.sol '["SubCredit Token", "SCT", 18]'
echo deploy contracts/DiscreditToken.sol '["Discredit Token", "DCT", 18]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DiscreditToken.sol '["Discredit Token", "DCT", 18]'

DepositTokenAddress=`cat solar.development.json |jq '.contracts."contracts/DepositToken.sol".address'`
CreditTokenAddress=`cat solar.development.json |jq '.contracts."contracts/CreditToken.sol".address'`
SubCreditTokenAddress=`cat solar.development.json |jq '.contracts."contracts/SubCreditToken.sol".address'`
DiscreditTokenAddress=`cat solar.development.json |jq '.contracts."contracts/DiscreditToken.sol".address'`

echo deploy contracts/DepositTokenController.sol '['$DepositTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DepositTokenController.sol '['$DepositTokenAddress']'
echo deploy contracts/CreditTokenController.sol '['$CreditTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/CreditTokenController.sol '['$CreditTokenAddress']'
echo deploy contracts/SubCreditTokenController.sol '['$SubCreditTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/SubCreditTokenController.sol '['$SubCreditTokenAddress']'
echo deploy contracts/DiscreditTokenController.sol '['$DiscreditTokenAddress']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DiscreditTokenController.sol '['$DiscreditTokenAddress']'

EasyDABFormulaAddress=`cat solar.development.json |jq '.contracts."contracts/EasyDABFormula.sol".address'`

DepositTokenControllerAddress=`cat solar.development.json |jq '.contracts."contracts/DepositTokenController.sol".address'`
CreditTokenControllerAddress=`cat solar.development.json |jq '.contracts."contracts/CreditTokenController.sol".address'`
SubCreditTokenControllerAddress=`cat solar.development.json |jq '.contracts."contracts/SubCreditTokenController.sol".address'`
DiscreditTokenControllerAddress=`cat solar.development.json |jq '.contracts."contracts/DiscreditTokenController.sol".address'`

BeneficiaryAddress=0xe28f6f97eb10fcb9b0edcf3a96e147f6fada72a7

echo deploy contracts/DABCreditAgent.sol '['$EasyDABFormulaAddress', '$CreditTokenControllerAddress', '$SubCreditTokenControllerAddress', '$DiscreditTokenControllerAddress', "'$BeneficiaryAddress'"]'

solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DABCreditAgent.sol '['$EasyDABFormulaAddress', '$CreditTokenControllerAddress', '$SubCreditTokenControllerAddress', '$DiscreditTokenControllerAddress', "'$BeneficiaryAddress'"]'

DABCreditAgentAddress=`cat solar.development.json |jq '.contracts."contracts/DABCreditAgent.sol".address'`

echo deploy contracts/DABDepositAgent.sol '['$DiscreditTokenAddress', '$EasyDABFormulaAddress', '$DepositTokenControllerAddress', "'$BeneficiaryAddress'"]'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DABDepositAgent.sol '['$DiscreditTokenAddress', '$EasyDABFormulaAddress', '$DepositTokenControllerAddress', "'$BeneficiaryAddress'"]'

DABDepositAgentAddress=`cat solar.development.json |jq '.contracts."contracts/DABDepositAgent.sol".address'`

now=`date +%s`
startTime=`expr $now + 60`

echo deploy contracts/DAB.sol '['$DABDepositAgentAddress', '$DABCreditAgentAddress', '$startTime']'
solar deploy --qtum_rpc=$QTUM_RPC --force --gasLimit=$GAS_LIMIT contracts/DAB.sol '['$DABDepositAgentAddress', '$DABCreditAgentAddress', '$startTime']'







