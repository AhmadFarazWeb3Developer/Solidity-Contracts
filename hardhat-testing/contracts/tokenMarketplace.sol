// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.22;
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Minimal interface to interact with any ERC20 without importing full PKBK contract. Keeps things clean.
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

// Abstract contract for a Token Marketplace that is Ownable (only the owner can perform certain actions).
contract TokenMarketPlace is Ownable, ReentrancyGuard {
    // Using SafeERC20 for safe transfers of ERC20 tokens and SafeMath for safe arithmetic operations.
    // Let me use the safe functions from SafeERC20 on any IERC20 variable.”
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public tokenPrice = 2e16 wei; // Initial token price set to 0.02 ETH.
    uint256 public sellerCount = 1;
    uint256 public buyerCount = 1;

    // ERC20 token interface for the PKBK token.
    IERC20 public pkbkToken; // pkbkToken is a state variable — it stores the token contract address.

    uint256 public previousAdjustedRatio;
    event TokenPriceUpdated(uint256 newPrice);
    event TokenBought(address indexed buyer, uint256 amount, uint256 tokenCost);
    event TokenSold(
        address indexed seller,
        uint256 amount,
        uint256 totalEarned
    );
    event TokenWithdrawn(address indexed owner, uint256 amount); // Emitted when tokens are withdrawn by the owner.
    event EtherWithdrawn(address indexed owner, uint256 amount); // Emitted when Ether is withdrawn by the owner

    // event calculateTokenPrice(uint256 priceToPay); // Emitted when the token price is calculated.

    // Constructor to initialize the contract with the PKBK token address.
    constructor(address _pkbkToken) {
        // Typecasting the address to IERC20 to use ERC20 functionalities.
        pkbkToken = IERC20(_pkbkToken);
    }

    // Function to adjust the token price based on market demand.
    function adjustTokenPriceBasedOnDemand() private {
        uint256 marketDemandRatio = buyerCount.mul(1e18).div(sellerCount);
        // console.log("Market Demand Ratio : ", marketDemandRatio);

        // Smoothing factor to stabilize the price adjustment.
        // Adding 1e18 ensures that the price does not drop too low when demand is low.
        uint256 smoothingFactor = 1e18;

        uint256 adjustedRatio = marketDemandRatio.add(smoothingFactor).div(2);
        // console.log("Adjusted Ratio : ", adjustedRatio);
        if (previousAdjustedRatio != adjustedRatio) {
            uint256 newTokenPrice = tokenPrice.mul(adjustedRatio).div(1e18);
            // console.log("New Token Price : ", newTokenPrice);

            uint256 minimumTokenPrice = 2e16 wei;
            if (newTokenPrice < minimumTokenPrice) {
                tokenPrice = minimumTokenPrice;
            } else {
                tokenPrice = newTokenPrice;
                emit TokenPriceUpdated(tokenPrice);
            }
        }
    }

    function buyPKBKToken(uint256 _amountOfToken) public payable nonReentrant {
        require(_amountOfToken > 0, "Amount Of Token > 0");
        uint256 requiredTokenPrice = calculateTokenPrice(_amountOfToken);
        require(requiredTokenPrice == msg.value, "Incorrect Token Price");
        pkbkToken.safeTransfer(msg.sender, _amountOfToken);
        buyerCount += 1;
        emit TokenBought(msg.sender, _amountOfToken, requiredTokenPrice);
    }

    function calculateTokenPrice(
        uint256 _amountOfToken
    ) public returns (uint256) {
        require(_amountOfToken > 0, "Amount Of Token > 0");
        // console.log(
        //     "Amount Of Tokens in Contract ",
        //     pkbkToken.balanceOf(address(this))
        // );
        adjustTokenPriceBasedOnDemand();
        uint256 amountToPay = _amountOfToken.mul(tokenPrice).div(1e18); // _amountOfToken * tokenPrice / 1e18
        // console.log("Amount To Pay", amountToPay);
        return amountToPay;
    }

    function sellPKBKToken(uint256 _amountOfToken) public payable {
        require(
            pkbkToken.balanceOf(msg.sender) >= _amountOfToken,
            "Invalid Amount Of Token"
        );
        uint256 priceToPayToUser = calculateTokenPrice(_amountOfToken);
        pkbkToken.safeTransferFrom(msg.sender, address(this), _amountOfToken);
        (bool success, ) = payable(msg.sender).call{value: priceToPayToUser}(
            ""
        );
        require(success, "Transaction Failed");
        emit TokenSold(msg.sender, _amountOfToken, priceToPayToUser);
    }

    function withDrawTokens(uint256 _amount) public onlyOwner {
        require(
            pkbkToken.balanceOf(address(this)) >= _amount,
            "Out Of Balance"
        );
        pkbkToken.safeTransfer(msg.sender, _amount);
        emit TokenWithdrawn(msg.sender, _amount);
    }

    function withDrawEthers(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Out of Ethers");
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transaction Failed");
        emit EtherWithdrawn(msg.sender, _amount);
    }

    // Accept ETH directly from another account
    receive() external payable {}
}
