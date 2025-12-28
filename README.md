# Secure Vault Authorization System

## Overview

This project implements a secure, production-style smart contract system for controlled fund withdrawals using a **two-contract architecture**. The system separates **fund custody** from **authorization validation**, mirroring real-world decentralized finance (DeFi) and custody designs.

The goal of this project is to demonstrate secure multi-contract design, replay protection, and deterministic state transitions under adversarial execution conditions.

---

## Architecture Summary

The system consists of **two on-chain smart contracts**:

### 1. SecureVault
- Holds native blockchain currency (ETH)
- Accepts deposits from any address
- Executes withdrawals only after authorization validation
- Never performs signature verification itself

### 2. AuthorizationManager
- Validates off-chain generated withdrawal permissions
- Verifies authorization authenticity
- Ensures each authorization is consumed **exactly once**
- Prevents replay attacks

The vault relies **exclusively** on the AuthorizationManager to approve withdrawals.

---

## Why Two Contracts?

Separating responsibilities improves security and clarity:

| Concern | Contract |
|------|--------|
| Asset custody | SecureVault |
| Permission validation | AuthorizationManager |

This design reduces risk, limits blast radius, and reflects patterns used in real Web3 protocols such as multisig wallets and DAO treasuries.

---

## Authorization Model

Withdrawals are permitted only through **off-chain generated authorizations**.

Each authorization is bound to:
- A specific vault address
- A specific blockchain network (chainId)
- A specific recipient address
- A specific withdrawal amount
- A unique authorization identifier (nonce)

### Replay Protection
- Each authorization can be used **only once**
- The AuthorizationManager tracks consumed authorizations
- Reuse attempts revert deterministically

---

## Security Guarantees

- ❌ Vault cannot bypass authorization checks
- ❌ Authorizations cannot be reused
- ❌ Unauthorized callers cannot influence state
- ✅ State updates occur before value transfer
- ✅ Cross-contract calls produce exactly one effect
- ✅ Initialization logic is protected

---

## Events & Observability

The system emits events for:
- Deposits
- Authorization consumption
- Successful withdrawals

All failed withdrawal attempts revert with deterministic behavior.

---

## Project Structure

