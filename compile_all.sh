#!/bin/bash

alias solc="solc --bin --asm --evm-version homestead"

if [ -d "build" ]; then
	rm -rf build
fi

SOURCE_DIR=solidity/contracts

solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/EasyDABFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DepositToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/CreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/SubCreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DiscreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DepositTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/CreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/SubCreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DiscreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DABDepositAgent.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DABCreditAgent.sol

solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DAB.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/DABWalletFactory.sol

solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/AMonthLoanPlanFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/AYearLoanPlanFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths $SOURCE_DIR -o build --overwrite $SOURCE_DIR/TwoYearLoanPlanFormula.sol


