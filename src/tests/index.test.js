const Contracts = require('../../src/index.js');
const Web3 = require('web3');
const assert = require('chai').assert;

describe('Contracts', () => {
  describe('constructor functions properly', () => {
    it('should construct object with contracts and classes', () => {
      const contracts = new Contracts(
        'ropsten',
        new Web3.providers.HttpProvider('https://morden.infura.io:8545'));

      assert.equal(typeof contracts.contracts, 'object');
      assert.equal(typeof contracts.CampaignRegistry, 'object');
      assert.equal(typeof contracts.CampaignRegistry.instance, 'function');
      assert.equal(typeof contracts.CampaignRegistry.instance(), 'object');
    });
  });
});
