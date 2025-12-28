// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 nonce,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    /// @notice Authorization manager contract
    IAuthorizationManager public immutable authorizationManager;

    /// @notice Emitted when ETH is deposited
    event Deposit(address indexed from, uint256 amount);

    /// @notice Emitted when ETH is withdrawn
    event Withdrawal(address indexed to, uint256 amount);

    constructor(address _authorizationManager) {
        require(_authorizationManager != address(0), "Invalid authorization manager");
        authorizationManager = IAuthorizationManager(_authorizationManager);
    }

    /// @notice Accept ETH deposits
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw ETH with valid authorization
     * @param recipient Address receiving ETH
     * @param amount Amount to withdraw
     * @param nonce Unique authorization nonce
     * @param signature Off-chain authorization signature
     */
    function withdraw(
        address payable recipient,
        uint256 amount,
        bytes32 nonce,
        bytes calldata signature
    ) external {
        require(address(this).balance >= amount, "Insufficient vault balance");

        // Verify authorization (will revert if invalid or reused)
        bool authorized = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            nonce,
            signature
        );

        require(authorized, "Authorization failed");

        // Transfer ETH AFTER state checks
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawal(recipient, amount);
    }
}
