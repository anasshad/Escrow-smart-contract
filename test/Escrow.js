const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Escrow", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const contractAmount = ONE_GWEI;
    const dueDate = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    const [buyer, seller] = await ethers.getSigners();

    const Escrow = await ethers.getContractFactory("Escrow");
    const escrow = await Escrow.deploy();

    return { escrow, dueDate, contractAmount, buyer, seller };
  }

  describe("Create Contract", function () {
    it("Should create contract", async function () {
      const { escrow, dueDate, contractAmount, buyer, seller } =
        await loadFixture(deployOneYearLockFixture);
      //Create contract
      await expect(
        await escrow.createContract(
          await buyer.getAddress(),
          await seller.getAddress(),
          "Contract Name",
          "This is the contract description",
          dueDate,
          escrow.address,
          {
            value: contractAmount,
          }
        )
      ).not.to.be.reverted;
      //
      await expect(
        await escrow.getContractState(
          "0xa16e02e87b7454126e5e10d957a927a7f5b5d2be"
        )
      ).to.equal(1);
    });

    it("Should deliver the order", async function () {});
  });
});
