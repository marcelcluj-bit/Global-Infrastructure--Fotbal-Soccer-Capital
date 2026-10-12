// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProFootballClubToken ($CLUB)
 * @dev Hybrid Governance & Fan Utility Token Framework for a $1B Valued Professional Football Club.
 * Allocates 60% Majority Stake to Majority Ownership and 40% Public/Institutional Tranche.
 */
contract ProFootballClubToken {
    string public name = "Pro Football Club Token";
    string public symbol = "CLUB";
    uint8 public decimals = 18;
    
    // Total Valuation: $1,000,000,000 USD represented as 1 Billion Tokens
    uint256 public totalSupply = 1000000000 * 10**18;

    address public majorityOwner; // Holds 60% ($600M)
    address public geminiAIOracle;
    
    uint256 public constant MAJORITY_SHARE = 600000000 * 10**18; // 60%
    uint256 public constant PUBLIC_TRANCHE  = 400000000 * 10**18; // 40%

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event DividendsDistributed(uint256 totalAmountUsd);
    event GovernanceVoteExecuted(string proposalTitle, bool passed);

    modifier onlyMajorityOwner() {
        require(msg.sender == majorityOwner, "Unauthorized: Only Majority Owner");
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == geminiAIOracle, "Unauthorized: Only Gemini AI Oracle");
        _;
    }

    constructor(address _majorityOwner, address _geminiAIOracle) {
        majorityOwner = _majorityOwner;
        geminiAIOracle = _geminiAIOracle;

        // Allocate 60% directly to Majority Owner, 40% to contract escrow for public/institutional sale
        balanceOf[majorityOwner] = MAJORITY_SHARE;
        balanceOf[address(this)] = PUBLIC_TRANCHE;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    // Unsold tokens return to majority owner treasury without diluting ownership
    function reclaimUnsoldTokens(uint256 _amount) external onlyMajorityOwner {
        require(balanceOf[address(this)] >= _amount, "Exceeds available public tranche balance");
        balanceOf[address(this)] -= _amount;
        balanceOf[majorityOwner] += _amount;
    }
}
