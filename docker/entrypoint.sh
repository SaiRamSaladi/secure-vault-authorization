#!/bin/sh
set -e
npx hardhat compile
npx hardhat run scripts/deploy.ts
