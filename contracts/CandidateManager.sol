// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "./interfaces/ICandidateManager.sol";
import "./libraries/Ownable.sol";
import "./libraries/SafeMath.sol";
import "./Candidate.sol";

contract CandidateManager is Ownable, ICandidateManager {
    using SafeMath for uint256;
    uint256 constant public BLOCK_PER_EPOCH = 900;

    constructor () {
        team = payable(msg.sender);
    }

    // only accept max node capacity => high reward for user
    uint256 public maxCapacity;

    // hardware fee  and other fee will transfer to team address
    address payable public team;

    address[] public candidates;

    struct CandidateState {
        uint256 capacity;
        bool isCandidate;
    }

    mapping(address => CandidateState) CandidatesState;

    event NewCandidate(address _candidate, string _name, address _coinbase);

    function setMaxCapacity(uint256 _maxCapacity) public onlyOwner {
        maxCapacity = _maxCapacity;
    }

    function newCandidate(string memory  _candidateName, address _coinbase) public onlyOwner {
        Candidate _candidate = new Candidate(_candidateName, _coinbase);
        CandidatesState[address(_candidate)] = CandidateState({
            capacity: 0,
            isCandidate: true
            });
        candidates.push(address(_candidate));
        emit NewCandidate(address(_candidate), _candidateName, _coinbase);
    }

    function changeTeamAddress(address payable _team) public onlyOwner {
        team = _team;
    }

    function getCandidates() public view returns (address[] memory) {
        return candidates;
    }

    function teamAddress() external view returns (address payable) {
        return team;
    }
    function currentEpoch() public view returns (uint256) {
        return block.number.sub(block.number.mod(BLOCK_PER_EPOCH)).div(BLOCK_PER_EPOCH);
    }
}