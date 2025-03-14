pragma solidity ^0.8.11;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {VoteResultNFT} from "./VegaNFT.sol";

contract Polling is ReentrancyGuard, Ownable {
    enum PollState {
        Active,
        Over
    }

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
    }

    struct Vote {
        string description;
        uint256 deadline;
        uint256 threshold;
        uint256 yess;
        uint256 nos;
        PollState state;
    }

    IERC20 public token;
    VoteResultNFT public nft;
    mapping(address => Stake) public stakes;
    mapping(uint256 => Vote) public polls;
    mapping(uint256 => mapping(address => bool)) public voted;
    uint256 public nextVoteId;

    constructor(address _token, address _nft) Ownable(msg.sender) {
        token = IERC20(_token);
        nft = VoteResultNFT(_nft);
    }

    function calculateVotingPower(address _user) internal view returns (uint256) {
        Stake memory stake = stakes[_user];
        if (stake.amount == 0) {
            return 0;
        }
        uint256 tleft = stake.duration - (block.timestamp - stake.startTime);
        return stake.amount * (tleft ** 2);
    }

  function stakeTokens(uint256 _amount, uint256 _duration) external nonReentrant {
        require(_amount > 0, "Invalid amount, must be > 0");
        require(_duration > 0 && _duration <= 4 * 365 days, "Invalid duration, must be: 0 < dur <= 4");
        require(stakes[msg.sender].amount == 0, "Already staked");

        token.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = Stake({
            amount: _amount, 
            startTime:
            block.timestamp, duration: _duration });
    }

    function initVote(string memory _description, 
                        uint256 _duration, 
                        uint256 _threshold
                       ) external onlyOwner {
        require(_duration > 0, "Duration must be > 0");
        require(_threshold > 0, "Threshold must be > 0 ");

        polls[nextVoteId] = Vote({
            description: _description,
            deadline: block.timestamp + _duration,
            threshold: _threshold,
            yess: 0,
            nos: 0,
            state: PollState.Active
        });
        nextVoteId++;
    }

    function vote_emission(uint256 _voteId, bool _choice) external nonReentrant {
        Vote storage _vote = polls[_voteId];
        require(_vote.state == PollState.Active, "Voting is over");
        require(block.timestamp < _vote.deadline, "Voting period ended");

        uint256 power = calculateVotingPower(msg.sender);
        require(power > 0, "User has no power to vote!");

        voted[_voteId][msg.sender] = true;
        
        if (_choice) {
            _vote.yess += power;
        } else {
            _vote.nos += power;
        }

        if (_vote.threshold <= 0 || block.timestamp >= _vote.deadline) {
            endVote(_voteId);
        }
    }

    function endVote(uint256 _voteId) public {
        Vote storage _vote = polls[_voteId];
        _vote.state = PollState.Over;
        bool result = _vote.yess > _vote.nos;
        VoteResultNFT.VoteResult memory info;
        info.id = _voteId;
        info.description = _vote.description;
        info.yess = _vote.yess;
        info.nos = _vote.nos;
        info.done = result;
        nft.mint(owner(), info);
    }
}
