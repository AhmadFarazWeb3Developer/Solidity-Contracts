const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const ERC712DeployedContract = buildModule("ERC712", (m) => {
  const erc712_contract = m.contract("ERC712");
  return { erc712_contract };
});

module.exports = MainDeployedContract;

