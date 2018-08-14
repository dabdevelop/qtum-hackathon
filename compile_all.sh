#!/bin/bash

alias solc="solc --bin --asm --evm-version homestead"

if [ -d "build" ]; then
	rm -rf build
fi

solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/EasyDABFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DepositToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/CreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/SubCreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DiscreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DepositTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/CreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/SubCreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DiscreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DABDepositAgent.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DABCreditAgent.sol

solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DAB.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/DABWalletFactory.sol

solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/AMonthLoanPlanFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/AYearLoanPlanFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths solidity/contracts -o build --overwrite solidity/contracts/TwoYearLoanPlanFormula.sol


