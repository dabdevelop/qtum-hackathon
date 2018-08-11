# DAB
### Testing

Tests are included and can be run on using [truffle](https://github.com/trufflesuite/truffle) and [testrpc](https://github.com/ethereumjs/testrpc).

    brew install npm
    npm install -g truffle
    npm install -g ethereumjs-testrpc

#### Prerequisites

    node v8.1.3+
    npm v5.3.0+
    truffle v3.4.5+
    testrpc v4.0.1+


#### Test and Migration on Different Ethereum Clients

##### Testrpc

Test in the development period.

To run the test, execute the following commands from the project's root folder.

    npm start
    npm test

##### Dev(Private Network)

Alpha test on private network.

To deploy, execute the following commands from the project's truffle folder.

    geth --dev --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpcapi="eth,net,web3" --mine --minerthreads=1 --unlock <Account>
    truffle migrate --network dev
    /Applications/Ethereum\ Wallet.app/Contents/MacOS/Ethereum\ Wallet --rpc http://localhost:8545

##### Rinkeby

Beta test on Rinkeby network.

To deploy, execute the following commands from the project's truffle folder.

    geth --rinkeby --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpcapi="eth,net,web3" --unlock <Account>
    truffle migrate --network rinkeby

You can get the Ether from [https://www.rinkeby.io](https://www.rinkeby.io)

##### Live

To operate on the main net of Ethereum.

To deploy, execute the following commands from the project's truffle folder.

    geth --rpc --rpcport 8545 --rpcaddr 127.0.0.1 --rpcapi="eth,net,web3" --unlock <Account>
    truffle migrate --network live

### Configuration

The structure of DAB  is showed in the grph.

![alt text](https://github.com/dabdevelop/contracts/raw/master/solidity/graphs/DAB_Hierarchy.jpg "DAB Hierarchy")

The deployer does some configurations after migration, the logic is like codes below.

        // Configure for Tokens
        await DepositToken.transferOwnership(DepositTokenController.address);
        await DepositTokenController.acceptTokenOwnership();
        await CreditToken.transferOwnership(CreditTokenController.address);
        await CreditTokenController.acceptTokenOwnership();
        await SubCreditToken.transferOwnership(SubCreditTokenController.address);
        await SubCreditTokenController.acceptTokenOwnership();
        await DiscreditToken.transferOwnership(DiscreditTokenController.address);
        await DiscreditTokenController.acceptTokenOwnership();

        // Configure for Controllers
        await DepositTokenController.transferOwnership(DABDepositAgent.address);
        await DABDepositAgent.acceptDepositTokenControllerOwnership();
        await CreditTokenController.transferOwnership(DABCreditAgent.address);
        await DABCreditAgent.acceptCreditTokenControllerOwnership();
        await SubCreditTokenController.transferOwnership(DABCreditAgent.address);
        await DABCreditAgent.acceptSubCreditTokenControllerOwnership();
        await DiscreditTokenController.transferOwnership(DABCreditAgent.address);
        await DABCreditAgent.acceptDiscreditTokenControllerOwnership();

        // Configure for Agents, WalletFactory and DAB
        await DABCreditAgent.setDepositAgent(DABDepositAgent.address);
        await DABDepositAgent.transferOwnership(DAB.address);
        await DAB.acceptDepositAgentOwnership();
        await DABCreditAgent.transferOwnership(DAB.address);
        await DAB.acceptCreditAgentOwnership();
        await DABWalletFactory.transferOwnership(DAB.address);
        await DAB.setDABWalletFactory(DABWalletFactory.address);
        await DAB.acceptDABWalletFactoryOwnership();
        await DAB.addLoanPlanFormula(HalfAYearLoanPlanFormula.address);
        await DAB.addLoanPlanFormula(AYearLoanPlanFormula.address);
        await DAB.addLoanPlanFormula(TwoYearLoanPlanFormula.address);
        await DAB.activate();

### Construction of DAB DAO
    1. construct four different smart tokens: deposit token, credit token, subCredit token, discredit token.
    2. construct four different SmartControllers with four  different smart tokens respectively, depositTokenController, creditTokenController, subCreditTokenController, discreditTokenController.
    3. transfer four smart tokens' ownership to the SmartControllers respectively.
    4. construct a DABDepositAgent with depositTokenController.
    5. construct a DABCreditAgent with creditTokenController, subCreditTokenController, discreditTokenController.
    6. transfer four SmartControllers' ownership to DABDepositAgent and DABCreditAgent respectively.
    7. construct a DAB with DABDepositAgent, DABCreditAgent and DABWalletFactory.
    8. transfer DABDepositAgent, DABCreditAgent and DABWalletFactory's ownership to DAB.
    9. transfer DAB's ownership to DAB DAO contract.
    10. DAB DAO can update the formulas (DAB formula and Loan plan formulas) and keep the ownership of DAB.
