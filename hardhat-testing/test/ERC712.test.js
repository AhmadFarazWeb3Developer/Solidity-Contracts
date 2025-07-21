const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Direct Spender Authorization", () => {
  async function deploy() {
    const [owner, spender, attacker] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("EIP712Auth");
    const contract = await Contract.deploy();
    return { contract, owner, spender, attacker };
  }

  it("should let owner authorize spender via signature", async () => {
    const { contract, owner, spender, attacker } = await loadFixture(deploy);

    // EIP-712 Setup
    const chainId = (await ethers.provider.getNetwork()).chainId;

    const domain = {
      name: "EIP712Auth",
      version: "1",
      chainId,
      verifyingContract: await contract.getAddress(),
    };

    const types = {
      Authorize: [
        { name: "authorizedUser", type: "address" },
        { name: "deadline", type: "uint256" },
      ],
    };

    // Use latest block timestamp
    const now = await time.latest();
    const deadline = now + 3600;

    // Owner creates signature authorizing spender
    const authMessage = {
      authorizedUser: spender.address,
      deadline,
    };

    // Generates an EIP-712 signature
    const signature = await owner.signTypedData(domain, types, authMessage);

    // Spender executes with their own address as msg.sender
    await contract.connect(spender).executeWithAuth(deadline, signature);

    expect(await contract.s_action()).to.be.true;

    // Attacker can't use the same signature (signature is bound to spender.address)
    await expect(
      contract.connect(attacker).executeWithAuth(deadline, signature)
    ).to.be.revertedWith("Invalid signature");

    // Advance block time past the deadline to test expiration logic
    await time.increaseTo(deadline + 1);

    // Signature should now be rejected as expired
    await expect(
      contract.connect(spender).executeWithAuth(deadline, signature)
    ).to.be.revertedWith("Signature expired");
  });
});
