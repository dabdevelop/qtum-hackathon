#!/bin/bash

solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/EasyDABFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DepositToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/CreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/SubCreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DiscreditToken.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DepositTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/CreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/SubCreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DiscreditTokenController.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DABDepositAgent.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DABCreditAgent.sol

solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DAB.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/DABWalletFactory.sol

solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/AMonthLoanPlanFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/AYearLoanPlanFormula.sol
solc ..=.. --optimize --bin --abi --hashes --allow-paths contracts -o build --overwrite contracts/TwoYearLoanPlanFormula.sol


