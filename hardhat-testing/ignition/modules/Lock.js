const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// Fixed unlock time (e.g., 1 hour after Jan 1, 2030 UTC)
const defaultUnlockTime = 1893452400n;
const tenEth = 10n * 10n ** 18n;

module.exports = buildModule("LockModule", (m) => {
  const unlockTime = m.getParameter("unlockTime", defaultUnlockTime);

  const lockedAmount = m.getParameter("lockedAmount", tenEth);

  const lock = m.contract("Lock", [unlockTime], {
    value: lockedAmount,
  });

  return { lock };
});
