// ignition/modules/ERC4337.js
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// const EP_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
module.exports = buildModule("ERC4337", (m) => {
  const entryPoint = m.contract("EntryPoint");
  // console.log(entryPoint);

  return {
    entryPoint,
  };
});
