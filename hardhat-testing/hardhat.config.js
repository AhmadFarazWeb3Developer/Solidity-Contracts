require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition"); // make sure this is included!

module.exports = {
  defaultNetwork: "localhost",
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
};
