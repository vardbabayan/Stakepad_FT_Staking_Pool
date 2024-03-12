/*
SPDX-License-Identifier: MIT
*/
pragma solidity ^0.8.15;

contract FTStakingPool {

    error InsufficientAmount(uint256 amount);

    struct User {
        uint256 amount;
        uint256 claimed;
    }

    struct Pool {
        uint256 totalStaked;
        uint256 totalClaimed;
        
        mapping (address => User) userInfo;
    }

    Pool public pool;

    uint256 public constant REWARD = 1000;

    /// function stake(amount)
    /// function unstake(amount)
    /// function claim() - user claims 1000 tokens

    function viewTokens(address user_address) public view returns(User memory user)  { 
        user = pool.userInfo[user_address];
        return user;
    } 

    function stake(uint256 amount) external {
        pool.userInfo[msg.sender].amount += amount;
        pool.totalStaked += amount;
    }

    function unstake(uint256 amount) external {
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
        
        user.claimed += REWARD;
        pool.totalClaimed += REWARD;
    }



}