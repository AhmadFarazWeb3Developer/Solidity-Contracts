const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const MainDeployedContract = buildModule("PKBK_module", (m) => {
  const initalSupply = m.getParameter("initialSupply", 1000n * 10n ** 18n);
  const pkbk_contract = m.contract("PKBK", [initalSupply]);
  const tokenMarketPlace_contract = m.contract("TokenMarketPlace", [
    pkbk_contract,
  ]);
  const voting_contract = m.contract("Voting", [pkbk_contract]);
  return { pkbk_contract, tokenMarketPlace_contract, voting_contract };
});

module.exports = MainDeployedContract;
