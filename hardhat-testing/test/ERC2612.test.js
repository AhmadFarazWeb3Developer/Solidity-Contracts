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
    const { contract, owner, spender, accepter } = await loadFixture(deploy);
    const chainId = (await ethers.provider.getNetwork()).chainId;

    //  EIP 712 - Domain Separtor
    const domain = {
      name: "My Token",
      version: "1",
      chainId,
      verifyingContract: await contract.getAddress(),
    };

    // EIP 712 - Action Type
    const types = {
      Permit: [
        { name: "owner", type: "address" },
        { name: "spender", type: "address" },
        { name: "value", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    };

    const nonce = await contract.nonces(owner.address);
    const value = 10n * 10n ** 18n;
    const deadline = (await time.latest()) + 3600;

    // EIP 712 -  Message
    const message = {
      owner: owner.address,
      spender: spender.address,
      value,
      nonce,
      deadline,
    };

    const signature = await owner.signTypedData(domain, types, message);
    const { v, r, s } = ethers.Signature.from(signature);

    await contract
      .connect(spender)
      .permit(owner.address, spender.address, value, deadline, v, r, s);

    expect(await contract.allowance(owner.address, spender.address)).to.equal(
      value
    );
    await contract
      .connect(spender)
      .transferFrom(owner.address, accepter.address, value);

    const newValue = 5n * 10n ** 18n;
    const newDeadline = (await time.latest()) + 3600;
    const newNonce = await contract.nonces(owner.address);

    const newMessage = {
      owner: owner.address,
      spender: accepter.address,
      value: newValue,
      nonce: newNonce,
      deadline: newDeadline,
    };

    const newSignature = await owner.signTypedData(domain, types, newMessage);
    const { v: newV, r: newR, s: newS } = ethers.Signature.from(newSignature);

    await contract
      .connect(accepter)
      .permit(
        owner.address,
        accepter.address,
        newValue,
        newDeadline,
        newV,
        newR,
        newS
      );

    expect(await contract.allowance(owner.address, accepter.address)).to.equal(
      newValue
    );
    await contract
      .connect(accepter)
      .transferFrom(owner.address, spender.address, newValue);
  });
});
