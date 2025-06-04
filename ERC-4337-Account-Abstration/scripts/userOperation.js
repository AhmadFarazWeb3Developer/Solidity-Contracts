const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

const sendToBundler = async () => {
  try {
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

    // Load deployment file
    let deployedAddresses;
    try {
      const data = fs.readFileSync(DEPLOYMENT_PATH, "utf-8");
      deployedAddresses = JSON.parse(data);
    } catch (error) {
      throw new Error(`Failed to read deployment file: ${error.message}`);
    }

    const entryPoint_ContractAddress = deployedAddresses["ERC4337#EntryPoint"];
    const factory_ContractAddress = deployedAddresses["ERC4337#AccountFactory"];

    if (!entryPoint_ContractAddress || !factory_ContractAddress) {
      throw new Error(
        "Missing EntryPoint or AccountFactory address in deployment file"
      );
    }

    // Contract instances
    const entryPoint_Contract = await hre.ethers.getContractAt(
      "EntryPoint",
      entryPoint_ContractAddress
    );
    const accountFactory_Contract = await hre.ethers.getContractAt(
      "AccountFactory",
      factory_ContractAddress
    );
    const account_Contract = await hre.ethers.getContractFactory("Account");

    // Predict wallet address, Calculate smart Wallet address before even deployed
    const sender = await hre.ethers.getCreateAddress({
      from: factory_ContractAddress,
      nonce: FACTORY_NONCE,
    });

    console.log("Sender Address:", sender);

    // Deposit ETH to EntryPoint
    await entryPoint_Contract.depositTo(sender, {
      value: hre.ethers.parseEther(DEPOSIT_AMOUNT),
    });

    console.log(`Deposited ${DEPOSIT_AMOUNT} ETH to EntryPoint for sender`);

    const [owner] = await hre.ethers.getSigners();

    // Generate initCode
    const code = await hre.ethers.provider.getCode(sender);
    const isDeployed = code !== "0x";
    const initCode = isDeployed
      ? "0x"
      : factory_ContractAddress +
        accountFactory_Contract.interface
          .encodeFunctionData("createAccount", [
            owner.address,
            entryPoint_ContractAddress,
          ])
          .slice(2);

    console.log("InitCode:", initCode);

    // Create UserOperation
    const nonce = await entryPoint_Contract.getNonce(sender, 0); // t retrieves the current UserOperation nonce for the smart contract wallet (aka the "Account").
    const userOp = {
      sender,
      nonce,
      initCode,
      callData: account_Contract.interface.encodeFunctionData("execute"),
      callGasLimit: GAS_CONFIG.callGasLimit,
      verificationGasLimit: GAS_CONFIG.verificationGasLimit,
      preVerificationGas: GAS_CONFIG.preVerificationGas,
      maxFeePerGas: GAS_CONFIG.maxFeePerGas,
      maxPriorityFeePerGas: GAS_CONFIG.maxPriorityFeePerGas,
      paymasterAndData: "0x",
      signature: "0x",
    };

    const opHash = await entryPoint_Contract.getUserOpHash(userOp);
    const signature = await owner.signMessage(hre.ethers.getBytes(opHash));
    userOp.signature = signature;

    console.log("UserOperation:", userOp);

    // Send to EntryPoint directly (acts like bundler)
    const tx = await entryPoint_Contract.handleOps([userOp], owner.address);
    const receipt = await tx.wait();
    console.log("Transaction Receipt:", receipt);
  } catch (error) {
    console.error("Error in sendToBundler:", error);
    throw error;
  }
};

sendToBundler().catch((error) => {
  console.error("Failed to execute sendToBundler:", error);
  process.exit(1);
});
