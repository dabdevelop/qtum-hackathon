

var AMonthLoanPlanFormula = artifacts.require("AMonthLoanPlanFormula.sol");
var HalfAYearLoanPlanFormula = artifacts.require("HalfAYearLoanPlanFormula.sol");
var AYearLoanPlanFormula = artifacts.require("AYearLoanPlanFormula.sol");
var TwoYearLoanPlanFormula = artifacts.require("TwoYearLoanPlanFormula.sol");
var EasyDABFormula = artifacts.require("EasyDABFormula.sol");
var DABDaoFormula = artifacts.require("DABDaoFormula.sol");

var DepositToken = artifacts.require("DepositToken.sol");
var CreditToken = artifacts.require("CreditToken.sol");
var SubCreditToken = artifacts.require("SubCreditToken.sol");
var DiscreditToken = artifacts.require("DiscreditToken.sol");
var VoteToken = artifacts.require("VoteToken.sol");

var DepositTokenController = artifacts.require('DepositTokenController.sol');
var CreditTokenController = artifacts.require('CreditTokenController.sol');
var SubCreditTokenController = artifacts.require('SubCreditTokenController.sol');
var DiscreditTokenController = artifacts.require('DiscreditTokenController.sol');
var VoteTokenController = artifacts.require("VoteTokenController.sol");

var DABWalletFactory = artifacts.require('DABWalletFactory.sol');

var DABDepositAgent = artifacts.require('DABDepositAgent.sol');
var DABCreditAgent = artifacts.require('DABCreditAgent.sol');

var LiveDAB = artifacts.require("DAB.sol");
var TestLoanPlanFormula = artifacts.require("./helpers/TestLoanPlanFormula.sol");
var TestDAB = artifacts.require("./helpers/TestDAB.sol");
var DAB;

var DABDao = artifacts.require("DABDao.sol");
var ProposalToAcceptDABOwnership = artifacts.require("ProposalToAcceptDABOwnership.sol");

let beneficiaryAddress = 0x0;

let startTime = Math.floor(Date.now() / 1000) + 15 * 24 * 60 * 60; // activation hasn't started
let startTimeInProgress = Math.floor(Date.now() / 1000) - 50 * 24 * 60 * 60; // ended


let duration = 15 * 24 * 60 * 60; // proposal duration


let approveAmount = Math.pow(10, 25);

let activate = true;


module.exports =  async (deployer, network) =>{

    if(network === "live"){
        beneficiaryAddress = '0xad8ff09670ce6560e58cc41103b708b77c7b6c59';
    } else if (network === "testnet"){
        beneficiaryAddress = '0xc3184b749f358c6326324e481d54e9a84d7fce29';
    } else if (network === "rinkeby"){
        beneficiaryAddress = '0xa77e2b295209ff3b6723a0becb50477ad51df124';
    } else if (network === "testrpc"){
        beneficiaryAddress = '0xa77e2b295209ff3b6723a0becb50477ad51df124';
    } else if (network === "dev"){
        beneficiaryAddress = '0x2D517c0755900A85C8a601F150ebe3684BC4Ad41';
    } else {throw("Unknown Network Configuration.");}



    deployer.deploy(AMonthLoanPlanFormula);
    deployer.deploy(HalfAYearLoanPlanFormula);
    deployer.deploy(AYearLoanPlanFormula);
    deployer.deploy(TwoYearLoanPlanFormula);
    await deployer.deploy(EasyDABFormula);
    await deployer.deploy(DABDaoFormula);
    await deployer.deploy(DepositToken, "Deposit Token", "DPT", 18);
    await deployer.deploy(DepositTokenController, DepositToken.address);
    await deployer.deploy(CreditToken, "Credit Token", "CDT", 18);
    await deployer.deploy(CreditTokenController, CreditToken.address);
    await deployer.deploy(SubCreditToken, "SubCredit Token", "SCT", 18);
    await deployer.deploy(SubCreditTokenController, SubCreditToken.address);
    await deployer.deploy(DiscreditToken, "Discredit Token", "DCT", 18);
    await deployer.deploy(DiscreditTokenController, DiscreditToken.address);
    await deployer.deploy(VoteToken, "Vote Token", "VOT", 18);
    await deployer.deploy(VoteTokenController, VoteToken.address);
    await deployer.deploy(DABCreditAgent, EasyDABFormula.address, CreditTokenController.address, SubCreditTokenController.address, DiscreditTokenController.address, beneficiaryAddress);
    await deployer.deploy(DABDepositAgent, DABCreditAgent.address, EasyDABFormula.address, DepositTokenController.address, beneficiaryAddress);

    // Main Net
    if(network === "live"){
        await deployer.deploy(LiveDAB, DABDepositAgent.address, DABCreditAgent.address, startTime);
        DAB = LiveDAB;
    } else if(network === "dev" || network === "testrpc" || network === "rinkeby" || network === "testnet"){
        deployer.deploy(TestLoanPlanFormula);
        await deployer.deploy(TestDAB, DABDepositAgent.address, DABCreditAgent.address, startTime, startTimeInProgress);
        DAB = TestDAB;
    } else {throw("Unknown Network Configuration.");}

    await deployer.deploy(DABWalletFactory, DAB.address);

    await deployer.deploy(DABDao, DAB.address, DABDaoFormula.address);

    await deployer.deploy(ProposalToAcceptDABOwnership, DABDao.address, VoteTokenController.address, "0x0", duration);

    if(activate){
        await DepositToken.deployed().then(async (instance) => {
            await instance.transferOwnership(DepositTokenController.address);
        });

        await DepositTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await CreditToken.deployed().then(async (instance) => {
            await instance.transferOwnership(CreditTokenController.address);
        });

        await CreditTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await SubCreditToken.deployed().then(async (instance) => {
            await instance.transferOwnership(SubCreditTokenController.address);
        });

        await SubCreditTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await DiscreditToken.deployed().then(async (instance) => {
            await instance.transferOwnership(DiscreditTokenController.address);
        });

        await DiscreditTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await VoteToken.deployed().then(async (instance) => {
            await instance.transferOwnership(VoteTokenController.address);
        });

        await VoteTokenController.deployed().then(async (instance) => {
            await instance.acceptTokenOwnership();
        });

        await DepositTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABDepositAgent.address);
        });

        await CreditTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABCreditAgent.address);
        });

        await SubCreditTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABCreditAgent.address);
        });

        await DiscreditTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(DABCreditAgent.address);
        });

        await VoteTokenController.deployed().then(async (instance) => {
            await instance.transferOwnership(ProposalToAcceptDABOwnership.address);
        });


        await DABDepositAgent.deployed().then(async (instance) => {
            await instance.acceptDepositTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.acceptCreditTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.acceptSubCreditTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.acceptDiscreditTokenControllerOwnership();
        });

        await ProposalToAcceptDABOwnership.deployed().then(async (instance) => {
            await instance.acceptVoteTokenControllerOwnership();
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.setDepositAgent(DABDepositAgent.address);
        });
        
        await DABDepositAgent.deployed().then(async (instance) => {
            await instance.transferOwnership(DAB.address);
        });

        await DABCreditAgent.deployed().then(async (instance) => {
            await instance.transferOwnership(DAB.address);
        });

        await DABWalletFactory.deployed().then(async (instance) => {
            await instance.transferOwnership(DAB.address);
        });

        await DAB.deployed().then(async (instance) => {
            await instance.acceptDepositAgentOwnership();
        });
        await DAB.deployed().then(async (instance) => {
            await instance.acceptCreditAgentOwnership();
        });

        await DAB.deployed().then(async (instance) => {
            await instance.setDABWalletFactory(DABWalletFactory.address);
        });

        await DAB.deployed().then(async (instance) => {
            await instance.acceptDABWalletFactoryOwnership();
        });

        await DAB.deployed().then(async (instance) => {
            await instance.addLoanPlanFormula(AMonthLoanPlanFormula.address);
        });

        await DAB.deployed().then(async (instance) => {
            await instance.addLoanPlanFormula(HalfAYearLoanPlanFormula.address);
        });

        await DAB.deployed().then(async (instance) => {
            await instance.addLoanPlanFormula(AYearLoanPlanFormula.address);
        });

        await DAB.deployed().then(async (instance) => {
            await instance.addLoanPlanFormula(TwoYearLoanPlanFormula.address);
        });

        await DAB.deployed().then(async (instance) => {
            await instance.activate();
        });


        // for basic test
        if(network === "dev" || network === "testrpc" || network === "rinkeby" || network === "testnet"){

            await DAB.deployed().then(async (instance) => {
                await instance.addLoanPlanFormula(TestLoanPlanFormula.address);
            });

            await DepositToken.deployed().then(async (instance) => {
                await instance.approve(DABDepositAgent.address, approveAmount);
            });

            await CreditToken.deployed().then(async (instance) => {
                await instance.approve(DABCreditAgent.address, approveAmount);
            });

            await SubCreditToken.deployed().then(async (instance) => {
                await instance.approve(DABCreditAgent.address, approveAmount);
            });

            await DiscreditToken.deployed().then(async (instance) => {
                await instance.approve(DABCreditAgent.address, approveAmount);
            });

            await DABWalletFactory.deployed().then(async (instance) => {
                await instance.newDABWallet();
            });

            await DAB.deployed().then(async (instance) => {
                await instance.transferOwnership(DABDao.address);
            });

            await DepositToken.deployed().then(async (instance) => {
                await instance.approve(DABDao.address, Math.pow(10, 24));
            });

            if(network === "dev" || network === "testrpc"){
                await DAB.deployed().then(async (instance) => {
                    await instance.deposit({value: Math.pow(10, 20)});

                    await instance.withdraw(Math.pow(10, 20));
                    await instance.cash(Math.pow(10, 20));

                });

                await DepositToken.deployed().then(async (instance) => {
                    await instance.transfer(ProposalToAcceptDABOwnership.address, Math.pow(10, 20));
                });

                await ProposalToAcceptDABOwnership.deployed().then(async (instance) => {
                    await instance.propose();
                });
            }
            
        }

    }

};