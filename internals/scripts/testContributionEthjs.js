const Eth = require('ethjs');
const SignerProvider = require('ethjs-provider-signer');
const sign = require('ethjs-signer').sign;
const contracts = require('../../src/lib/contracts.json');
const account = require('../../../account.json');

const environment = 'ropsten';
const campaignAddress = '0x301241bea2b33306f1fdcf3fc52c103b5892e50b';

const eth = new Eth(new SignerProvider(`https://${environment}.infura.io`, {
  signTransaction: (rawTx, cb) => cb(null, sign(rawTx, account.privateKey)),
  accounts: (cb) => cb(null, [account.address]),
}), { debug: true });
const defaultTxObject = {
  from: account.address,
  value: Eth.toWei('0.2', 'ether'),
  gasPrice: Eth.toWei('0.00000002', 'ether'),
  gas: 3200000,
};
const StandardCampaign = eth.contract(
  JSON.parse(contracts.StandardCampaign.interface),
  contracts.StandardCampaign.bytecode,
  defaultTxObject);
const campaign = StandardCampaign.at(campaignAddress);

const interval = setInterval(() => {
  console.log('This will still run.');
}, 500);

console.log(JSON.parse(contracts.StandardCampaign.interface));

// contirbute msg value
campaign.contributeMsgValue([0], (err, result) => {
  console.log(err, result);
  clearInterval(interval);
});
