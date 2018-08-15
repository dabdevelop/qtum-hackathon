const ora = require("ora")

const {
    Qtum,
  } = require("qtumjs")
  
const repoData = require("./solar.development.json")
const qtum = new Qtum("http://qtum:test@localhost:3889", repoData)

const SOURCE_DIR = 'solidity/contracts/'

const fromAddr = "qeDKhVC2rqpWQpwty52UsE9Nsi1jUarsyJ"

const AMonthLoanPlanFormula = qtum.contract(SOURCE_DIR + "AMonthLoanPlanFormula.sol")
const HalfAYearLoanPlanFormula = qtum.contract(SOURCE_DIR + "HalfAYearLoanPlanFormula.sol")
const AYearLoanPlanFormula = qtum.contract(SOURCE_DIR + "AYearLoanPlanFormula.sol")
const TwoYearLoanPlanFormula = qtum.contract(SOURCE_DIR + "TwoYearLoanPlanFormula.sol")

const DepositToken = qtum.contract(SOURCE_DIR + "DepositToken.sol")
const CreditToken = qtum.contract(SOURCE_DIR + "CreditToken.sol")
const SubCreditToken = qtum.contract(SOURCE_DIR + "SubCreditToken.sol")
const DiscreditToken = qtum.contract(SOURCE_DIR + "DiscreditToken.sol")

const DepositTokenController = qtum.contract(SOURCE_DIR + "DepositTokenController.sol")
const CreditTokenController = qtum.contract(SOURCE_DIR + "CreditTokenController.sol")
const SubCreditTokenController = qtum.contract(SOURCE_DIR + "SubCreditTokenController.sol")
const DiscreditTokenController = qtum.contract(SOURCE_DIR + "DiscreditTokenController.sol")

const DABCreditAgent = qtum.contract(SOURCE_DIR + "DABCreditAgent.sol")
const DABDepositAgent = qtum.contract(SOURCE_DIR + "DABDepositAgent.sol")
const DABWalletFactory = qtum.contract(SOURCE_DIR + "DABWalletFactory.sol")

const DAB = qtum.contract(SOURCE_DIR + "DAB.sol")

async function transferOwnership(fromAddr, target, to){
  const tx = await target.send("transferOwnership", [to.address], {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transferOwnership to " + to.address)
  await confirmation
}

async function acceptTokenOwnership(fromAddr, target){
  const tx = await target.send("acceptTokenOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptTokenOwnership")
  await confirmation
}

async function acceptDepositTokenControllerOwnership(fromAddr, target){
  const tx = await target.send("acceptDepositTokenControllerOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptDepositTokenControllerOwnership")
  await confirmation
}

async function acceptCreditTokenControllerOwnership(fromAddr, target){
  const tx = await target.send("acceptCreditTokenControllerOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptCreditTokenControllerOwnership")
  await confirmation
}

async function acceptSubCreditTokenControllerOwnership(fromAddr, target){
  const tx = await target.send("acceptSubCreditTokenControllerOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptSubCreditTokenControllerOwnership")
  await confirmation
}

async function acceptDiscreditTokenControllerOwnership(fromAddr, target){
  const tx = await target.send("acceptDiscreditTokenControllerOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptDiscreditTokenControllerOwnership")
  await confirmation
}

async function setDepositAgent(fromAddr, target, to){
  const tx = await target.send("setDepositAgent", [to.address], {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm setDepositAgent to " + to.address)
  await confirmation
}

async function acceptDepositAgentOwnership(fromAddr, target){
  const tx = await target.send("acceptDepositAgentOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptDepositAgentOwnership")
  await confirmation
}

async function acceptCreditAgentOwnership(fromAddr, target){
  const tx = await target.send("acceptCreditAgentOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptCreditAgentOwnership")
  await confirmation
}

async function setDABWalletFactory(fromAddr, target, to){
  const tx = await target.send("setDABWalletFactory", [to.address], {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm setDABWalletFactory to " + to.address)
  await confirmation
}

async function acceptDABWalletFactoryOwnership(fromAddr, target){
  const tx = await target.send("acceptDABWalletFactoryOwnership", "", {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm acceptDABWalletFactoryOwnership")
  await confirmation
}

async function addLoanPlanFormula(fromAddr, target, to){
  const tx = await target.send("addLoanPlanFormula", [to.address], {
    senderAddress: fromAddr,
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm addLoanPlanFormula: " + to.address)
  await confirmation
}

async function activate(fromAddr, target){
  const tx = await target.send("activate", "", {
    senderAddress: fromAddr,
    gasLimit: 1000000
  })
  console.log("send tx:", tx.txid)
  // console.log(tx)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm activate")
  await confirmation
}

async function deploy(){
  // await transferOwnership(fromAddr, DepositToken, DepositTokenController)
  // await transferOwnership(fromAddr, CreditToken, CreditTokenController)
  // await transferOwnership(fromAddr, SubCreditToken, SubCreditTokenController)
  // await transferOwnership(fromAddr, DiscreditToken, DiscreditTokenController)

  // await acceptTokenOwnership(fromAddr, DepositTokenController)
  // await acceptTokenOwnership(fromAddr, CreditTokenController)
  // await acceptTokenOwnership(fromAddr, SubCreditTokenController)
  // await acceptTokenOwnership(fromAddr, DiscreditTokenController)
  
  // await transferOwnership(fromAddr, DepositTokenController, DABDepositAgent)
  // await transferOwnership(fromAddr, CreditTokenController, DABCreditAgent)
  // await transferOwnership(fromAddr, SubCreditTokenController, DABCreditAgent)
  // await transferOwnership(fromAddr, DiscreditTokenController, DABCreditAgent)

  // await acceptDepositTokenControllerOwnership(fromAddr, DABDepositAgent)
  // await acceptCreditTokenControllerOwnership(fromAddr, DABCreditAgent)
  // await acceptSubCreditTokenControllerOwnership(fromAddr, DABCreditAgent)
  // await acceptDiscreditTokenControllerOwnership(fromAddr, DABCreditAgent)

  // await setDepositAgent(fromAddr, DABCreditAgent, DABDepositAgent)

  // await transferOwnership(fromAddr, DABDepositAgent, DAB)
  // await transferOwnership(fromAddr, DABCreditAgent, DAB)
  // await transferOwnership(fromAddr, DABWalletFactory, DAB)

  // await acceptDepositAgentOwnership(fromAddr, DAB)
  // await acceptCreditAgentOwnership(fromAddr, DAB)

  // await setDABWalletFactory(fromAddr, DAB, DABWalletFactory)
  // await acceptDABWalletFactoryOwnership(fromAddr, DAB)

  // await addLoanPlanFormula(fromAddr, DAB, AMonthLoanPlanFormula)
  // await addLoanPlanFormula(fromAddr, DAB, HalfAYearLoanPlanFormula)
  // await addLoanPlanFormula(fromAddr, DAB, AYearLoanPlanFormula)
  // await addLoanPlanFormula(fromAddr, DAB, TwoYearLoanPlanFormula)

  await activate(fromAddr, DAB)
}

deploy()