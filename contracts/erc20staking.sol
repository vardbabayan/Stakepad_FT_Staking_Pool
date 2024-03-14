/*
SPDX-License-Identifier: MIT
*/
pragma solidity ^0.8.15;

contract FTStakingPool {

    error InsufficientAmount(uint256 amount);

    struct User {
        uint256 amount;
        uint256 claimed;
        uint256 pendingReward;
        uint256 rewardDebt;
    }

    struct Pool {
        uint256 totalStaked;
        uint256 totalClaimed;
        uint256 totalReward;
        uint256 lastAccessedBlock;
        uint256 rewardTokenPerBlock;
        uint256 accumulatedRewardTokenPerShare;
        mapping (address => User) userInfo;
    }


    Pool public pool;

    function setAccumulatedTokenPerShare() internal {
        if(block.number <= pool.lastAccessedBlock){
            return;
        }
        uint256 blockDifference = block.number - pool.lastAccessedBlock;
        uint256 totalNewReward = pool.rewardTokenPerBlock * blockDifference;
        pool.accumulatedRewardTokenPerShare += totalNewReward/pool.totalStaked;
    }
    function getUserRewardDebt() internal view returns (uint256){
        User memory user = pool.userInfo[msg.sender];
        return user.amount * pool.accumulatedRewardTokenPerShare;
    }
    function setUserPendingRewards() internal returns (uint256){
        User storage user = pool.userInfo[msg.sender];
        uint256 pendingReward = (user.amount * pool.accumulatedRewardTokenPerShare) - user.rewardDebt ;
        user.pendingReward += pendingReward;
        user.rewardDebt = user.amount * pool.accumulatedRewardTokenPerShare;
        return pendingReward;
    }


    function viewTokens(address user_address) public view returns(User memory user)  { 
        user = pool.userInfo[user_address];
        return user;
    } 

    function stake(uint256 amount) external {
        setUserPendingRewards();
        pool.userInfo[msg.sender].amount += amount;
        pool.totalStaked += amount;
    }

    function unstake(uint256 amount) external {
        setUserPendingRewards();
        User storage user = pool.userInfo[msg.sender];
        if (user.amount < amount)
            revert InsufficientAmount(user.amount);

        // require(user.amount >= amount, "Insufficient staked amount");
        
        user.amount -= amount;
        pool.totalStaked -= amount;
    }

    function claim() external {
        User storage user = pool.userInfo[msg.sender];

        if (user.amount < 100)
            revert InsufficientAmount(user.amount);

        // require(user.amount >= 100, "Insufficient amount of tokens");
        uint256 pendingRewards = setUserPendingRewards();
        user.claimed += pendingRewards;
        pool.totalClaimed += pendingRewards;
    }

}