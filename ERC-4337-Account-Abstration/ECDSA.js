const { ethers } = require("ethers");

const ECDSA = async () => {
  // Random private key
  const privateKey =
    "0x0123456789012345678901234567890123456789012345678901234567890123";
  const wallet = new ethers.Wallet(privateKey);

  // Extracting public key (address) from private key
  const publicKey = wallet.address;
  console.log("Public Address:", publicKey);

  // Message
  const message = "Hello World";

  // Sign the message
  const signature = await wallet.signMessage(message);
  console.log("Signature:", signature);

  // Splitting signature into r, s, v
  const sig = ethers.Signature.from(signature);
  console.log("r:", sig.r);
  console.log("s:", sig.s);
  console.log("v:", sig.v); // public key identifier

  // Hashing the message
  const messageHash = ethers.hashMessage(message);
  //   console.log("Message Hash : ", messageHash);

  // Recovering the address from signature
  const recoveredAddress = ethers.recoverAddress(messageHash, signature);
  console.log("Recovered Address:", recoveredAddress);

  // Verify
  if (recoveredAddress.toLowerCase() === publicKey.toLowerCase()) {
    console.log("Signature Verified");
  } else {
    console.log("Signature Verification Failed");
  }
};

ECDSA().catch((err) => {
  console.error(err);
});
