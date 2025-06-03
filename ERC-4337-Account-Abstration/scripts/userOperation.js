const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

const deploymentPath = path.join(
  __dirname,
  "../ignition/deployments/chain-31337/deployed_addresses.json"
);

const deployedAddresses = JSON.parse(fs.readFileSync(deploymentPath, "utf-8"));

console.log("Deployed Address ", deployedAddresses);

const FACTORY_NONCE = 1;

// Extract the deployed addresses

const EP_ADDRESS = deployedAddresses["ERC4337#EntryPoint"];
const FACTORY_ADDRESS = deployedAddresses["ERC4337#AccountFactory"];

console.log("Entry Point Address : ", EP_ADDRESS);
console.log("Factory Address : ", FACTORY_ADDRESS);

const sentToBundler = async () => {
  const entryPoint = await hre.ethers.getContractAt("EntryPoint", EP_ADDRESS);
  const sender = await hre.ethers.getCreateAddress({
    from: FACTORY_ADDRESS,
    nonce: FACTORY_NONCE,
  });

  const AccountFactory = await hre.ethers.getContractFactory("AccountFactory");
  const [owner] = await hre.ethers.getSigners();

  // const initCode =
  //   FACTORY_ADDRESS +
  //   AccountFactory.interface
  //     .encodeFunctionData("createAccount", [owner.address, EP_ADDRESS])
  //     .slice(2);

  const code = await hre.ethers.provider.getCode(sender);
  const isDeployed = code !== "0x";

  const initCode = isDeployed
    ? "0x"
    : FACTORY_ADDRESS +
      AccountFactory.interface
        .encodeFunctionData("createAccount", [owner.address, EP_ADDRESS])
        .slice(2);

  await entryPoint.depositTo(sender, {
    value: await hre.ethers.parseEther("100"),
  });

  const Account = await hre.ethers.getContractFactory("Account");

  const UserOperation = {
    sender,
    nonce: await entryPoint.getNonce(sender, 0),
    initCode,
    callData: Account.interface.encodeFunctionData("execute"),
    callGasLimit: 200_000,
    verificationGasLimit: 1000_000,
    preVerificationGas: 50_000,
    maxFeePerGas: await hre.ethers.parseUnits("10", "gwei"),
    maxPriorityFeePerGas: await hre.ethers.parseUnits("5", "gwei"),
    paymasterAndData: "0x",
    signature: "0x",
  };

  // Generate hash
  const opHash = await entryPoint.getUserOpHash(UserOperation);
  // Sign the userOpHash with your smart wallet owner’s private key:
  const sig = await owner.signMessage(await hre.ethers.getBytes(opHash));

  UserOperation.signature = sig;

  // For the time beings we are on local so that why we are not using
  // api for bundler

  const tx = await entryPoint.handleOps([UserOperation], owner.address);
  const receipt = await tx.wait();
  console.log(receipt);

  /*
    eth_sendUserOperation
   Submits a user operation to a Bundler. If the request is successful,
   the endpoint will return a user operation hash that the caller can use
   to look up the status of the user operation.
    If it fails, or another error occurs, an error code and 
    description will be returned.
    
    */
};

sentToBundler().catch((err) => {
  console.error(err);
});
