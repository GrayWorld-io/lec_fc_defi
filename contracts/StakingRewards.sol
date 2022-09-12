// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingRewards is Ownable {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    // 스테이킹이 끝나는 시간
    uint256 public periodFinish = 0;

    // 초당 리워드의 개수
    uint256 public rewardRate = 0;

    // 스테이킹 기간
    uint256 public rewardsDuration = 365 days;

    //마지막 업데이트 시간(스테이킹 수량 변경 시점)
    uint256 public lastUpdateTime;

    // 현재 구간에서 시간 변화에 따른 리워드 총합 / totalSupply
    uint256 public rewardPerTokenStored;

    // 이미 획득한 리워드의 총합(스테이킹 자산 0인 구간도 포함)
    mapping(address => uint256) public userRewardPerTokenPaid;

    // 출금 가능한 누적된 리워드의 총합
    mapping(address => uint256) public rewards;

    //전체 스테이킹된 토큰 개수
    uint256 private _totalSupply;

    // 유저의 스테이킹 개수
    mapping(address => uint256) private _balances;

    constructor(address _rewardsToken, address _stakingToken) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyOwner
        updateReward(address(0))
    {
        // 처음 비율을 설정하거나 스테이킹 기간이 끝난 경우
        // periodFinish의 초기값은 0이다.
        if (block.timestamp >= periodFinish) {
            //reward가 31536000 (60*60*24*365)라면 1초당 1개의 리워드 코인이 분배된다.
            rewardRate = reward / rewardsDuration;
        } else {
            //스테이킹 종료 전 추가로 리워드를 배정하는 경우
            uint256 remaning = periodFinish - block.timestamp;
            uint256 leftover = remaning * rewardRate;
            rewardRate = reward + leftover / rewardsDuration;
        }

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance / rewardsDuration,
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;

        // 스테이킹 종료 시간 업데이트, 현재 시간에서 1년을 연장한다.
        periodFinish = block.timestamp + rewardsDuration;
    }

    // crucial functions

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - lastUpdateTime) * 1e18) /
            _totalSupply;
    }

    // 지금까지 나의 총 보상을 조회
    function earned(address account) public view returns (uint256) {
        // _balances[account] * rewardPerToken() -> account의 총 보상
        // _balances[account] * userRewardPerTokenPaid[account] -> 내가 이미 획득한 보상
        // rewards[account] account가 출금 가능한 누적된 보상
        return
            (_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) /
            1e18 +
            rewards[account];
    }

    modifier updateReward(address account) {
        //현재 시점에서 토큰당 리워드의 총합을 구한다.
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
}
