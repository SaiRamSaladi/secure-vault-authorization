import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const network = await deployer.provider?.getNetwork();

  console.log("Deploying with account:", deployer.address);
  console.log("Chain ID:", network?.chainId.toString());

  // Deploy AuthorizationManager
  const AuthorizationManager = await ethers.getContractFactory(
    "AuthorizationManager"
  );
  const authorizationManager = await AuthorizationManager.deploy();
  await authorizationManager.waitForDeployment();

  const authAddress = await authorizationManager.getAddress();
  console.log("AuthorizationManager deployed to:", authAddress);

  // Deploy SecureVault
  const SecureVault = await ethers.getContractFactory("SecureVault");
  const vault = await SecureVault.deploy(authAddress);
  await vault.waitForDeployment();

  const vaultAddress = await vault.getAddress();
  console.log("SecureVault deployed to:", vaultAddress);

  console.log("Deployment completed successfully ✅");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
