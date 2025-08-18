const { ethers } = require("hardhat");
const { expect } = require("chai");
const { ZeroAddress } = require("ethers");
const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("TokenWithdrawModule Tests", function () {

  // Define variables
  let deployer;
  let alice;
  let bob;
  let charlie;
  let masterCopy;
  let token;
  let safe;
  let safeAddress;
  let chainId;

  /**
   * Executes a transaction on the Safe contract.
   * @param {Array} wallets - The signers of the transaction.
   * @param {Object} safe - The Safe contract instance.
   * @param {string} to - The address to send the transaction to.
   * @param {BigInt} value - The value to send with the transaction.
   * @param {string} data - The data to send with the transaction.
   * @param {number} operation - The operation type (0 for call, 1 for delegate call).
   */
  
  const execTransaction = async function (
    wallets,
    safe,
    to,
    value,
    data,
    operation
  ) {
    // Get the current nonce of the Safe contract
    const nonce = await safe.nonce();

    // Get the transaction hash for the Safe transaction
    const transactionHash = await safe.getTransactionHash(
      to,
      value,
      data,
      operation,
      0,
      0,
      0,
      ZeroAddress,
      ZeroAddress,
      nonce
    );

    let signatureBytes = "0x";
    const bytesDataHash = ethers.getBytes(transactionHash);

    // Get the addresses of the signers
    const addresses = await Promise.all(
      wallets.map((wallet) => wallet.getAddress())
    );

    // Sort the signers by their addresses
    const sorted = wallets.sort((a, b) => {
      const addressA = addresses[wallets.indexOf(a)];
      const addressB = addresses[wallets.indexOf(b)];
      return addressA.localeCompare(addressB, "en", { sensitivity: "base" });
    });

    // Sign the transaction hash with each signer
    for (let i = 0; i < sorted.length; i++) {
      const flatSig = (await sorted[i].signMessage(bytesDataHash))
        .replace(/1b$/, "1f")
        .replace(/1c$/, "20");
      signatureBytes += flatSig.slice(2);
    }

    // Execute the transaction on the Safe contract
    await safe.execTransaction(
      to,
      value,
      data,
      operation,
      0,
      0,
      0,
      ZeroAddress,
      ZeroAddress,
      signatureBytes
    );
  };

  // Setup signers and deploy contracts before running tests
  before(async () => {
    [deployer, alice, bob, charlie] = await ethers.getSigners();

    chainId = (await ethers.provider.getNetwork()).chainId;
    const safeFactory = await ethers.getContractFactory("Safe", deployer);
    masterCopy = await safeFactory.deploy();

    // Deploy a new token contract
    const TestTokenFactory = await ethers.getContractFactory(
      "TestToken",
      deployer
    );
    token = await TestTokenFactory.deploy("test", "T");

    // Deploy a new SafeProxyFactory contract
    const ProxyFactoryContract = await ethers.getContractFactory(
      "SafeProxyFactory",
      deployer
    );
    const proxyFactory = await ProxyFactoryContract.deploy();

    // Setup the Safe, Step 1, generate transaction data
    const safeData = masterCopy.interface.encodeFunctionData("setup", [
      [await alice.getAddress()],
      1,
      ZeroAddress,
      "0x",
      ZeroAddress,
      ZeroAddress,
      0,
      ZeroAddress,
    ]);

    // Read the safe address by executing the static call to createProxyWithNonce function
    safeAddress = await proxyFactory.createProxyWithNonce.staticCall(
      await masterCopy.getAddress(),
      safeData,
      0n
    );

    if (safeAddress === ZeroAddress) {
      throw new Error("Safe address not found");
    }

    // Setup the Safe, Step 2, execute the transaction
    await proxyFactory.createProxyWithNonce(
      await masterCopy.getAddress(),
      safeData,
      0n
    );

    safe = await ethers.getContractAt("Safe", safeAddress);

    // Mint tokens to the safe address
    await token
      .connect(deployer)
      .mint(safeAddress, BigInt(10) ** BigInt(18) * BigInt(100000));
  });

  // A Safe Module is a smart contract that is allowed to execute transactions on behalf of a Safe Smart Account.
  // This function deploys the TokenWithdrawModule contract and enables it in the Safe.
  const enableModule = async () => {
    // Deploy the TokenWithdrawModule contract and pass the token and safe address as arguments
    const TokenWithdrawModuleFactory = await ethers.getContractFactory(
      "TokenWithdrawModule",
      deployer
    );
    const tokenWithdrawModule = await TokenWithdrawModuleFactory.deploy(
      token.target,
      safeAddress
    );

    // Enable the module in the safe, Step 1, generate transaction data
    const enableModuleData = masterCopy.interface.encodeFunctionData(
      "enableModule",
      [tokenWithdrawModule.target]
    );

    // Enable the module in the safe, Step 2, execute the transaction
    await execTransaction([alice], safe, safe.target, 0, enableModuleData, 0);

    // Verify that the module is enabled
    expect(await safe.isModuleEnabled.staticCall(tokenWithdrawModule.target)).to
      .be.true;

    return { tokenWithdrawModule };
  };

  // Test case to verify token transfer to bob
  it("Should successfully transfer tokens to bob", async function () {
    // Enable the module in the Safe
    const { tokenWithdrawModule } = await enableModule();

    const amount = 10000000000000000000n; // 10 * 10^18
    const deadline = 100000000000000n;
    const nonce = await tokenWithdrawModule.nonces(await bob.getAddress());

    // Our module expects a EIP-712 typed signature, so we need to define the EIP-712 domain
    const domain = {
      name: "TokenWithdrawModule",
      version: "1",
      chainId: chainId,
      verifyingContract: await tokenWithdrawModule.getAddress(),
    };

    // EIP-712 types
    const types = {
      TokenWithdrawModule: [
        { name: "amount", type: "uint256" },
        { name: "beneficiary", type: "address" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    };

    // EIP-712 values
    const value = {
      amount: amount,
      beneficiary: await bob.getAddress(),
      nonce: nonce,
      deadline: deadline,
    };

    // Hash the data using EIP-712
    const digest = ethers.TypedDataEncoder.hash(domain, types, value);
    const bytesDataHash = ethers.getBytes(digest);
    let signatureBytes = "0x";

    // Alice signs the digest
    const flatSig = (await alice.signMessage(bytesDataHash))
      .replace(/1b$/, "1f")
      .replace(/1c$/, "20");
    signatureBytes += flatSig.slice(2);

    // Test that an invalid signer cannot call the module even with a valid signature
    // We test this before the valid transaction, because it would fail because of an invalid nonce otherwise
    await expect(
      tokenWithdrawModule
        .connect(charlie)
        .tokenTransfer(
          amount,
          await charlie.getAddress(),
          deadline,
          signatureBytes
        )
    ).to.be.revertedWith("GS026");

    // Now we use the signature to transfer via our module
    await tokenWithdrawModule
      .connect(bob)
      .tokenTransfer(amount, await bob.getAddress(), deadline, signatureBytes);

    // Verify the token balance of bob (should be 10000000000000000000)
    const balanceBob = await token.balanceOf.staticCall(await bob.getAddress());
    expect(balanceBob).to.be.equal(amount);

    console.log(
      "✅ Token transfer successful! Bob's balance:",
      balanceBob.toString()
    );
  });

  // Additional test case for deployment verification
  it("Should deploy contracts correctly", async function () {
    expect(await safe.getAddress()).to.not.equal(ZeroAddress);
    expect(await token.getAddress()).to.not.equal(ZeroAddress);
    expect(await safe.getThreshold()).to.equal(1);
    expect(await safe.getOwners()).to.deep.equal([await alice.getAddress()]);

    const safeBalance = await token.balanceOf(safeAddress);
    expect(safeBalance).to.equal(BigInt(10) ** BigInt(18) * BigInt(100000));

    console.log("✅ All contracts deployed correctly");
    console.log("Safe address:", safeAddress);
    console.log("Token address:", await token.getAddress());
    console.log("Safe token balance:", safeBalance.toString());
  });
});
