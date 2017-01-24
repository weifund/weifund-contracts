# User Guide

All information for developers using weifund-contracts should consult this document.

## Install

```
npm install --save weifund-contracts
```

## Usage

```js
// require the WeiFund contracts repo and instantiate it
const Contracts = require('weifund-contracts');
const contracts = new Contracts('ropsten', web3.currentProvider);

// util helpers
const unixDay = 24 * 24 * 60;
const currentUnixTime = ((new Date()).getTime() / 1000);
const oneEther = 1000000000000000000;
const myAddress = '0xd89b8a74c153f0626497bc4a531f702c6a4b285f';
const enhancerAddress = '0x0000000000000000000000000000000000000000';

// setup the registry, this is the pre deployed instance on the selected network
const campaignRegistry = contracts.CampaignRegistry.instance();

// StanardCampaign Contract Instance
const someCampaign = contracts.StandardCampaign.factory.at('0x00...');

// New StandardCampaign
contracts.StandardCampaign.factory.new("My Campaign Name", // name
  currentUnixTime + (60 * unixDay), // expiry
  50 * oneEther, // fundingGoal
  myAddress, // beneficiary
  myAddress, // owner
  enhancerAddress,
  {from: myAddress, gas: 3000000}, function(err, result){});
```

## WeiFund Contracts Object

```js
{
  StandardCampaign: {...},
  Campaign: {...},
  Token: {...},
  Owned: {...},
  IssuedToken: {...},
  MultiSigWallet: {...},
  CurationRegistry: {...}, // .instance() available
  CampaignRegistry: {...}, // .instance() available
  CampaignDataRegistry: {...}, // .instance() available
  StandardCampaignFactory: {...}, // .instance() available
  MultiSigWalletFactory: {...}, // .instance() available
  IssuedTokenFactory: {...}, // .instance() available
  Model1EnhancerFactory: {...}, // .instance() available
}
```
