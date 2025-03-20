// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityToken {
    string public name = "CommunityToken";
    string public symbol = "CTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public rewards;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event RewardIssued(address indexed user, uint256 amount);

    constructor() {
        totalSupply = 1000000 * (10 ** uint256(decimals)); // Initial supply
        balanceOf[msg.sender] = totalSupply; // Assign initial supply to contract creator
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function rewardUser (address _user, uint256 _amount) external {
        require(_user != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than zero");

        rewards[_user] += _amount;
        totalSupply += _amount; // Increase total supply
        balanceOf[_user] += _amount; // Mint tokens to the user
        emit RewardIssued(_user, _amount);
    }

    function getRewardBalance(address _user) external view returns (uint256) {
        return rewards[_user];
    }

    function withdrawRewards() external {
        uint256 rewardAmount = rewards[msg.sender];
        require(rewardAmount > 0, "No rewards to withdraw");

        rewards[msg.sender] = 0; // Reset the reward balance
        totalSupply += rewardAmount; // Increase total supply
        balanceOf[msg.sender] += rewardAmount; // Mint tokens to the user
        emit RewardIssued(msg.sender, rewardAmount);
    }
}
