const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const pkbk_deployedContract = buildModule("PKBK_module", (m) => {
  const initalSupply = m.getParameter("initialSupply", 1000n * 10n ** 18n);
  const pkbk = m.contract("PKBK", [initalSupply]);
  return { pkbk };
});

module.exports = pkbk_deployedContract;
