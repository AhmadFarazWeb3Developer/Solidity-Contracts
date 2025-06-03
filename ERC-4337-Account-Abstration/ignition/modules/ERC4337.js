// ignition/modules/ERC4337.js
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ERC4337", (m) => {
  const entryPoint = m.contract("EntryPoint");
  const factoryContract = m.contract("AccountFactory");

  return {
    entryPoint,
    factoryContract,
  };
});
