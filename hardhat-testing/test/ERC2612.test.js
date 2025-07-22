const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Direct Spender Authorization", () => {
  async function deploy() {
    const [owner, spender, attacker, accepter] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("ERC2612");
    const INITIAL_SUPPLY = 100n * 10n ** 18n;
    const contract = await Contract.deploy(INITIAL_SUPPLY);
    return { contract, owner, spender, attacker, accepter, INITIAL_SUPPLY };
  }

  it("should let owner authorize spender via signature", async () => {
    const { contract, owner, spender, attacker, accepter } = await loadFixture(
      deploy
    );

    // EIP-712 Setup
    const chainId = (await ethers.provider.getNetwork()).chainId;

    const domain = {
      name: "My Token",
      version: "1",
      chainId,
      verifyingContract: await contract.getAddress(),
    };

    const types = {
      Permit: [
        { name: "owner", type: "address" },
        { name: "spender", type: "address" },
        { name: "value", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    };

    // Get nonce and set values
    const nonce = await contract.nonces(owner.address);
    console.log(nonce);

    const value = 10n * 10n ** 18n; // 10 tokens

    const deadline = (await time.latest()) + 3600;

    // Create permit message
    const message = {
      owner: owner.address,
      spender: spender.address,
      value,
      nonce,
      deadline,
    };

    // Sign the permit message
    const signature = await owner.signTypedData(domain, types, message);

    // Split signature correctly
    const { v, r, s } = ethers.Signature.from(signature);

    // Call permit with correct parameters
    await contract.connect(spender).permit(
      owner.address, // owner
      spender.address, // spender
      value, // value
      deadline, // deadline
      v, // v (uint8)
      r, // r (bytes32)
      s // s (bytes32)
    );

    expect(await contract.allowance(owner.address, spender.address)).to.equal(
      value
    );

    await contract.connect(spender).transferFrom(owner, accepter, value);

    // expect(await contract.allowance(owner.address, spender.address)).to.equal(
    //   value
    // );
  });
});
