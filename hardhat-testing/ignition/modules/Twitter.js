const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const TwitterContractDeployment = buildModule("Twitter", (m) => {
  const twitter_contract = m.contract("Twitter");
  return { twitter_contract };
});

module.exports = TwitterContractDeployment;
