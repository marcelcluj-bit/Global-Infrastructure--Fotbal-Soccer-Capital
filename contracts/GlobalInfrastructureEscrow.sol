// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title GlobalInfrastructureEscrow
 * @dev Manages institutional tranches and milestone-based releases for $1B RWA tokenization.
 */
contract GlobalInfrastructureEscrow {
    address public owner;
    address public geminiAIOracle;
    bool public auditCompliancePassed = true;
    
    mapping(address => uint256) public institutionalDeposits;

    event TrancheReleased(address indexed recipient, uint256 amount, string milestone);
    event ComplianceStatusUpdated(bool status);

    modifier onlyOracleOrOwner() {
        require(msg.sender == owner || msg.sender == geminiAIOracle, "Unauthorized access");
        _;
    }

    constructor(address _geminiAIOracle) {
        owner = msg.sender;
        geminiAIOracle = _geminiAIOracle;
    }

    function updateComplianceStatus(bool _status) external onlyOracleOrOwner {
        auditCompliancePassed = _status;
        emit ComplianceStatusUpdated(_status);
    }

    function releaseTranche(address recipient, uint256 amount, string memory milestone) external onlyOracleOrOwner {
        require(auditCompliancePassed, "CRITICAL: Funds locked due to compliance audit failure!");
        require(address(this).balance >= amount, "Insufficient escrow balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");

        emit TrancheReleased(recipient, amount, milestone);
    }

    receive() external payable {}
}
