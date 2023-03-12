const { expect } = require("chai");
const { ethers } = require("hardhat");

let token;
let fundraising;
let deployer; // admin
let poolAddress;
let accounts;

describe("FlashLoan", () => {
  before(async () => {
    accounts = await ethers.getSigners();
    deployer = accounts[0];

    const Token = await ethers.getContractFactory("CollieCoin"); // deployting token contract
    token = await Token.deploy();

    const Fundraising = await ethers.getContractFactory("FundRaising"); // deploying Fundraising Pool contract
    fundraising = await Fundraising.deploy(token.address);

    let TokenAddress = token.address;
    poolAddress = await fundraising.getPoolAddress(TokenAddress);

    // addresses of each wallet

    // 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 100
    // 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC 100
    // 0x90F79bf6EB2c4f870365E785982E1f101E93b906 100
    // 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 100
    // 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc 50
    // 0x976EA74026E726554dB657fA54763abd0C3a0aa9 50
    //
  });

  describe("Deployment", () => {
    it("minting 100 tokens to all accounts", async () => {
      await token.mint(accounts[1].address, "200000000000000000000");
      await token.mint(accounts[2].address, "100000000000000000000");
      await token.mint(accounts[3].address, "100000000000000000000");
      await token.mint(accounts[4].address, "100000000000000000000");
      await token.mint(accounts[5].address, "100000000000000000000");
      await token.mint(accounts[6].address, "100000000000000000000");
    });

    it("approving 100 tokens to pool", async () => {
      await token
        .connect(accounts[1])
        .approve(poolAddress, "100000000000000000000");
      await token
        .connect(accounts[2])
        .approve(poolAddress, "100000000000000000000");
      await token
        .connect(accounts[3])
        .approve(poolAddress, "100000000000000000000");
      await token
        .connect(accounts[4])
        .approve(poolAddress, "100000000000000000000");
      await token
        .connect(accounts[5])
        .approve(poolAddress, "100000000000000000000");
      await token
        .connect(accounts[6])
        .approve(poolAddress, "100000000000000000000");
    });
    it("adding tokens to pool", async () => {
      await fundraising.connect(accounts[1]).addFundsToPool(poolAddress, 100);
      await fundraising.connect(accounts[2]).addFundsToPool(poolAddress, 100);
      await fundraising.connect(accounts[3]).addFundsToPool(poolAddress, 100);
      await fundraising.connect(accounts[4]).addFundsToPool(poolAddress, 100);
      await fundraising.connect(accounts[5]).addFundsToPool(poolAddress, 100);
      await fundraising.connect(accounts[6]).addFundsToPool(poolAddress, 100);
    });

    it("verify reward is being sent to owner once winner is choosen", async () => {
      // fetching tax
      const Tax = await fundraising.getTax(poolAddress);
      // fetching threshold
      const Threshold = await fundraising.getThreshold(poolAddress);
      // fetching balance of main smart contract where tax will be sent
      const balanceOfOwner = await token.balanceOf(fundraising.address);
      // calculating tax
      const CalculatedTax = (Tax / 10000) * Threshold;
      // maintaing decimals
      const expected = CalculatedTax * 10 ** 18; // this is total tax should be sent to owner smart contract

      expect(expected.toString()).to.equal(balanceOfOwner.toString());
      // const poolBalance = await fundraising.getWinnerAddress(poolAddress);
      // console.log(poolBalance);
    });

    it("verifying reward is being sent to winner address", async () => {
      // fetching tax
      const Tax = await fundraising.getTax(poolAddress);
      // fetching threshold
      const Threshold = await fundraising.getThreshold(poolAddress);
      // fetching balance of main smart contract where tax will be sent
      const balanceOfOwner = await token.balanceOf(fundraising.address);
      // calculating tax
      const CalculatedTax = (Tax / 10000) * Threshold;
      // maintaing decimals
      const expected = CalculatedTax * 10 ** 18;
      const ThresholdMaintained = Threshold * 10 ** 18;
      //
      const reward = ThresholdMaintained - expected; // this is total reward that the winner should have

      const winnerAddress = await fundraising.getWinnerAddress(poolAddress); // fetching winner address using poolAddress
      const currentBalance = await token.balanceOf(winnerAddress); // fetching current balance of winner

      expect(currentBalance.toString()).to.equal(reward.toString()); // comparing current balance and the winning amount of the pool
    });
  });
});
