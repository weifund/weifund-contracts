const Web3 = require('web3');
const SignerProvider = require('ethjs-provider-signer');
const sign = require('ethjs-signer').sign;
const account = require('../../../../account.json');
const Contracts = require('../../src/index.js');

const environment = 'ropsten';
const campaignAddress = '0x301241bea2b33306f1fdcf3fc52c103b5892e50b';

const web3 = new Web3(new SignerProvider(`https://${environment}.infura.io`, {
  signTransaction: (rawTx, cb) => cb(null, sign(rawTx, account.privateKey)),
  accounts: (cb) => cb(null, [account.address]),
}), { debug: true });
const contracts = new Contracts('ropsten', web3.currentProvider);

const defaultTxObject = {
  from: account.address,
  value: web3.toWei('0.2', 'ether'),
  gasPrice: web3.toWei('0.00000002', 'ether'),
  gas: 3000000,
};
const interval = setInterval(() => {}, 500);

const campaign = contracts.StandardCampaign.factory.at(campaignAddress);

campaign.contributeMsgValue([0], defaultTxObject, (err, result) => {
  console.log(err, result);
  clearInterval(interval);
});
