const Eth = require('ethjs');
const sign = require('ethjs-signer').sign;
const fs = require('fs');
const contracts = require('../../src/lib/contracts.json');
const account = require('../../../account.json'); // eslint-disable-line
const outputFileJSON = './src/lib/environments.json';
const currentEnvironmentsOutput = require('../../src/lib/environments.json');
const getTransactionSuccess = require('./utils.js').getTransactionSuccess;
const bnToString = require('./utils.js').bnToString;
const contractFactory = require('./utils.js').contractFactory;
const deepAssign = require('assign-deep');
const zeroClientProvider = require('web3-provider-engine/zero'); // eslint-disable-line

const environment = 'mainnet';
const rpcUrl = 'https://mainnet.infura.io';

console.log('Account being used: ', account.address); // eslint-disable-line

const provider = zeroClientProvider({
  rpcUrl,
  getAccounts: (cb) => {
    cb(null, [account.address.toLowerCase()]);
  },
  signTransaction: (rawTx, cb) => {
    cb(null, sign(rawTx, account.privateKey.toLowerCase()));
  },
});
provider.start();
provider.stop();

const eth = new Eth(provider, { debug: true });
const defaultTxObject = {
  from: account.address,
  gasPrice: Eth.toWei('0.00000002', 'ether'),
  gas: 3000000,
};

const IssuedTokenFactory = contractFactory(eth, contracts, 'IssuedTokenFactory', defaultTxObject);
const StandardCampaignFactory = contractFactory(eth, contracts, 'StandardCampaignFactory', defaultTxObject);
const MultiSigWalletFactory = contractFactory(eth, contracts, 'MultiSigWalletFactory', defaultTxObject);
const CampaignDataRegistry = contractFactory(eth, contracts, 'CampaignDataRegistry', defaultTxObject);
const CampaignRegistry = contractFactory(eth, contracts, 'CampaignRegistry', defaultTxObject);
const CurationRegistry = contractFactory(eth, contracts, 'CurationRegistry', defaultTxObject);
const EmptyEnhancer = contractFactory(eth, contracts, 'EmptyEnhancer', defaultTxObject);
const Model1EnhancerFactory = contractFactory(eth, contracts, 'Model1EnhancerFactory', defaultTxObject);

console.log('deploying contracts.. here we go...!'); // eslint-disable-line

deployWeiFundServices((deployError, result) => {
  if (deployError) { throw deployError; }

  const scopedOutput = deepAssign({}, currentEnvironmentsOutput, {
    [environment]: bnToString(result, 16, true),
  });
  const receiptsOutput = JSON.stringify(scopedOutput);

  fs.writeFile(outputFileJSON, receiptsOutput, (writeError) => {
    if (writeError) { throw writeError; }

    console.log('All contracts deployed, file saved!'); // eslint-disable-line
  });
});

function deployWeiFundServices(callback) {
  // deployed contract instances
  var deployed = {}; // eslint-disable-line

  Model1EnhancerFactory.new().then((txHashModel1) => {
    getTransactionSuccess(eth, txHashModel1, (err0Model1, Model1EnhancerFactoryResult) => {
      if (err0Model1) { callback(err0Model1, null); return; }

      deployed = Object.assign({}, deployed, {
        Model1EnhancerFactory: Model1EnhancerFactoryResult,
      });

      MultiSigWalletFactory.new().then((txHash0) => {
        getTransactionSuccess(eth, txHash0, (err0, MultiSigWalletFactoryResult) => {
          if (err0) { callback(err0, null); return; }

          deployed = Object.assign({}, deployed, {
            MultiSigWalletFactory: MultiSigWalletFactoryResult,
          });

          IssuedTokenFactory.new().then((txHashToken) => {
            getTransactionSuccess(eth, txHashToken, (err1Token, IssuedTokenFactoryResult) => {
              if (err1Token) { callback(err1Token, null); return; }

              deployed = Object.assign({}, deployed, {
                IssuedTokenFactory: IssuedTokenFactoryResult,
              });

              StandardCampaignFactory.new().then((txHash2) => {
                getTransactionSuccess(eth, txHash2, (err1, StandardCampaignFactoryResult) => {
                  if (err1) { callback(err1, null); return; }

                  deployed = Object.assign({}, deployed, {
                    StandardCampaignFactory: StandardCampaignFactoryResult,
                  });

                  CampaignDataRegistry.new().then((txHash4) => {
                    getTransactionSuccess(eth, txHash4, (err3, CampaignDataRegistryResult) => {
                      if (err3) { callback(err3, null); return; }

                      deployed = Object.assign({}, deployed, {
                        CampaignDataRegistry: CampaignDataRegistryResult,
                      });

                      CampaignRegistry.new().then((txHash5) => {
                        getTransactionSuccess(eth, txHash5, (err4, CampaignRegistryResult) => {
                          if (err4) { callback(err4, null); return; }

                          deployed = Object.assign({}, deployed, {
                            CampaignRegistry: CampaignRegistryResult,
                          });

                          CurationRegistry.new().then((txHash6) => {
                            getTransactionSuccess(eth, txHash6, (err5, CurationRegistryResult) => {
                              if (err5) { callback(err5, null); return; }

                              deployed = Object.assign({}, deployed, {
                                CurationRegistry: CurationRegistryResult,
                              });

                              EmptyEnhancer.new().then((txHash7) => {
                                getTransactionSuccess(eth, txHash7, (err6, EmptyEnhancerResult) => {
                                  if (err6) { callback(err6, null); return; }

                                  deployed = Object.assign({}, deployed, {
                                    EmptyEnhancer: EmptyEnhancerResult,
                                  });

                                  callback(null, deployed);
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  })
  .catch((err) => {
    callback(err, null);
  });
}
