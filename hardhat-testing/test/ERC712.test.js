const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect, version } = require("chai");

describe("EIP712 Signature Verification", () => {
  const deployedEIP712Contract = async () => {
    const [owner, spender, attacker] = await ethers.getSigners();
    const CONTRACT = await ethers.getContractFactory("EIP712");
    const deployedContract = await CONTRACT.deploy(spender);
    await deployedContract.waitForDeployment();

    return { deployedContract, owner, spender, attacker };
  };

  it("should sign EIP712 message and verify on-chain", async () => {
    const { deployedContract, owner, spender } = await loadFixture(
      deployedEIP712Contract
    );

    // Implementing EIP712 now

    // 1. EIP-712 Domain seperator

    const chainId = await owner.getChainId();

    domain = {
      name: "My Dapp",
      version: 1,
      chainId: chainId,
      verifyingContract: await deployedContract.address(),
    };

    // 2. EIP-712 types

    types = {
      SetValue: [
        { name: "caller", type: "address" },
        { name: "deadline", type: "uint256" },
      ],
    };

    // 3. Message to Sign
    message = {
      caller: spender.address,
      deadline: Math.floor(Date.now() / 1000) + 3600,
    };

    const signature = await owner.signTypedData(domain, types, message);
    const deadline = Math.floor(Date.now() / 1000) + 3600;

    await deployedContract.connect(user).setValue(deadline, signature);
  });
});
