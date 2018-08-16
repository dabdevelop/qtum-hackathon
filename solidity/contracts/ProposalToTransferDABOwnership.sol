pragma solidity ^0.4.11;

import './interfaces/IDABDao.sol';
import './Proposal.sol';

/*
    DAB DAO Proposal v0.1

    Proposal to execute privilege functions transferDABOwnership in DAO
*/
contract ProposalToTransferDABOwnership is Proposal {

/**
    @dev constructor

    @param _dao      dao
    @param _voteTokenController      vote token controller
    @param _proposalContract      contract proposed in proposal
    @param _duration      duration of proposal
*/
    constructor(
    IDABDao _dao,
    SmartTokenController _voteTokenController,
    address _proposalContract,
    uint256 _duration)
    public
    Proposal(_dao, _voteTokenController, _proposalContract, _duration)
    {}

/**
    @dev execute the proposal
*/
    function execute() public excuteStage {
    // transfer DAB ownership
        dao.transferDABOwnership();
    }

}
