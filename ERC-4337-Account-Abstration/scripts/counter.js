const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

const deploymentPath = path.join(
  __dirname,
  "../ignition/deployments/chain-31337/deployed_addresses.json"
);

const deployedAddresses = JSON.parse(fs.readFileSync(deploymentPath, "utf-8"));
const FACTORY_ADDRESS = deployedAddresses["ERC4337#AccountFactory"];

const FACTORY_NONCE = 1;

const CountUpdates = async () => {
  const accountAddress = await hre.ethers.getCreateAddress({
    from: FACTORY_ADDRESS,
    nonce: FACTORY_NONCE,
  });

  const account = await hre.ethers.getContractAt("Account", accountAddress);
  const count = await account.count(); // assuming count() is a public view function
  console.log("Current count value:", count.toString());
};

CountUpdates().catch((err) => {
  console.error(err);
});
