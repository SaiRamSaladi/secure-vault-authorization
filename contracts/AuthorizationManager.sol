// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AuthorizationManager {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    /// @notice Tracks used authorization identifiers
    mapping(bytes32 => bool) public usedAuthorizations;

    /// @notice Emitted when an authorization is consumed
    event AuthorizationConsumed(bytes32 indexed authId);

    /**
     * @notice Verifies and consumes a withdrawal authorization
     * @param vault The vault contract address
     * @param recipient The address receiving funds
     * @param amount The amount approved for withdrawal
     * @param nonce Unique authorization identifier
     * @param signature Off-chain signature approving the withdrawal
     */
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 nonce,
        bytes calldata signature
    ) external returns (bool) {
        // Create deterministic authorization ID
        bytes32 authId = keccak256(
            abi.encodePacked(
                vault,
                recipient,
                amount,
                block.chainid,
                nonce
            )
        );

        // Ensure authorization is unused
        require(!usedAuthorizations[authId], "Authorization already used");

        // Apply Ethereum signed message prefix
        bytes32 ethSignedMessage = authId.toEthSignedMessageHash();

        // Recover signer
        address signer = ECDSA.recover(ethSignedMessage, signature);

        require(signer != address(0), "Invalid signature");

        // Mark authorization as consumed BEFORE returning
        usedAuthorizations[authId] = true;

        emit AuthorizationConsumed(authId);

        return true;
    }
}
