const contractData = require('./lib/contracts.json');
const receipts = require('./lib/environments.json');
const Web3 = require('web3');

function generateObjectFor(network, contractName, web3) {
  const factory = web3.eth.contract(JSON.parse(contractData[contractName].interface));
  const networkReceipts = receipts[network] || {};
  const receipt = networkReceipts[contractName] || {};
  const instance = () => factory.at(receipt.contractAddress || '');

  return Object.assign({}, contractData[contractName], { receipt, factory, instance });
}

module.exports = function Contracts(network, provider) { // eslint-disable-line
  const web3 = new Web3(provider);
  const self = this;
  self.contracts = contractData;
  self.receipts = receipts;

  Object.keys(contractData).forEach((contractName) => {
    Object.defineProperty(self, contractName, {
      enumerable: true,
      value: generateObjectFor(network, contractName, web3),
    });
  });
};
