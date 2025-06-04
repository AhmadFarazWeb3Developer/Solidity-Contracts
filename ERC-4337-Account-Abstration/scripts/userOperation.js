const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

// Constants
const DEPLOYMENT_PATH = path.join(
  __dirname,
  "../ignition/deployments/chain-31337/deployed_addresses.json"
);
const FACTORY_NONCE = 1;
const DEPOSIT_AMOUNT = "100"; // ETH
const GAS_CONFIG = {
  callGasLimit: 200_000,
  verificationGasLimit: 1_000_000,
  preVerificationGas: 50_000,
  maxFeePerGas: hre.ethers.parseUnits("10", "gwei"),
  maxPriorityFeePerGas: hre.ethers.parseUnits("5", "gwei"),
};

// Load deployed contract addresses
const loadDeployedAddresses = () => {
  try {
    const data = fs.readFileSync(DEPLOYMENT_PATH, "utf-8");
    return JSON.parse(data);
  } catch (error) {
    throw new Error(`Failed to read deployment file: ${error.message}`);
  }
};

// Get contract instances
const getContracts = async (deployedAddresses) => {
  const entryPointAddress = deployedAddresses["ERC4337#EntryPoint"];
  const factoryAddress = deployedAddresses["ERC4337#AccountFactory"];

  if (!entryPointAddress || !factoryAddress) {
    throw new Error(
      "Missing EntryPoint or AccountFactory address in deployment file"
    );
  }

  const entryPoint = await hre.ethers.getContractAt(
    "EntryPoint",
    entryPointAddress
  );
  const accountFactory = await hre.ethers.getContractFactory("AccountFactory");
  const account = await hre.ethers.getContractFactory("Account");

  return { entryPoint, accountFactory, account, factoryAddress };
};

// Calculate sender address
const getSenderAddress = async (factoryAddress) => {
  const sender = await hre.ethers.getCreateAddress({
    from: factoryAddress,
    nonce: FACTORY_NONCE,
  });
  return sender;
};

// Generate initCode for wallet deployment
const getInitCode = async (
  accountFactory,
  factoryAddress,
  ownerAddress,
  entryPointAddress,
  sender
) => {
  const code = await hre.ethers.provider.getCode(sender);
  const isDeployed = code !== "0x";

  if (isDeployed) return "0x";

  return (
    factoryAddress +
    accountFactory.interface
      .encodeFunctionData("createAccount", [ownerAddress, entryPointAddress])
      .slice(2)
  );
};

// Create and sign UserOperation
const createUserOperation = async (entryPoint, account, sender, initCode) => {
  const nonce = await entryPoint.getNonce(sender, 0);
  const userOp = {
    sender,
    nonce,
    initCode,
    callData: account.interface.encodeFunctionData("execute"),
    callGasLimit: GAS_CONFIG.callGasLimit,
    verificationGasLimit: GAS_CONFIG.verificationGasLimit,
    preVerificationGas: GAS_CONFIG.preVerificationGas,
    maxFeePerGas: await GAS_CONFIG.maxFeePerGas,
    maxPriorityFeePerGas: await GAS_CONFIG.maxPriorityFeePerGas,
    paymasterAndData: "0x",
    signature: "0x",
  };

  const opHash = await entryPoint.getUserOpHash(userOp);
  const [owner] = await hre.ethers.getSigners();
  const signature = await owner.signMessage(hre.ethers.getBytes(opHash));
  userOp.signature = signature;

  return userOp;
};

// Main function to submit UserOperation
const sendToBundler = async () => {
  try {
    // Load deployed addresses
    const deployedAddresses = loadDeployedAddresses();
    console.log("Deployed Addresses:", deployedAddresses);

    // Get contract instances
    const { entryPoint, accountFactory, account, factoryAddress } =
      await getContracts(deployedAddresses);
    console.log("EntryPoint Address:", deployedAddresses["ERC4337#EntryPoint"]);
    console.log("AccountFactory Address:", factoryAddress);

    // Calculate sender address
    const sender = await getSenderAddress(factoryAddress);
    console.log("Sender Address:", sender);

    // Deposit funds to EntryPoint for sender
    await entryPoint.depositTo(sender, {
      value: hre.ethers.parseEther(DEPOSIT_AMOUNT),
    });
    console.log(`Deposited ${DEPOSIT_AMOUNT} ETH to EntryPoint for sender`);

    // Generate initCode
    const [owner] = await hre.ethers.getSigners();
    const initCode = await getInitCode(
      accountFactory,
      factoryAddress,
      owner.address,
      deployedAddresses["ERC4337#EntryPoint"],
      sender
    );
    console.log("InitCode:", initCode);

    // Create and sign UserOperation
    const userOp = await createUserOperation(
      entryPoint,
      account,
      sender,
      initCode
    );
    console.log("UserOperation:", userOp);

    // Submit UserOperation to EntryPoint (simulating bundler)
    // Note: Using handleOps directly since we're on a local network (no bundler API)
    const tx = await entryPoint.handleOps([userOp], owner.address);
    const receipt = await tx.wait();
    console.log("Transaction Receipt:", receipt);

    /*
     * eth_sendUserOperation:
     * In a production environment, a bundler would submit the UserOperation via an API.
     * If successful, it returns a userOpHash to track status. If it fails, an error is returned.
     * Here, we use handleOps directly for local testing.
     */
  } catch (error) {
    console.error("Error in sendToBundler:", error);
    throw error;
  }
};

// Execute the main function
sendToBundler().catch((error) => {
  console.error("Failed to execute sendToBundler:", error);
  process.exit(1);
});
