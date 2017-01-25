#WeiFund Bug Bounty Program

Thank you for visiting the WeiFund Bug Bounty.

WeiFund is crowdfunding infrastructure on and for the Ethereum ecosystem. Successful bug hunters will be rewarded with up to $5,000 in ether and recognition on our website and github page (See Rewards & Rules section below for details).

Below you'll find all the details on this program. If you've already read this information and have found a bug you'd like to submit to WeiFund for review, please use this form: [Submit a Bug](https://goo.gl/forms/R0w3vaKdjv3s7SqY2).

A great place to learn about our platform's technical design and operation is in our [concise documentation](https://weifund.readthedocs.io/en/latest/).

In addition to reviewing our github repositories, [two WeiFund campaigns](https://weifund.surge.sh) serving as honey pots, are already live on the mainnet. WeiFund will be funding these campaigns over the course of the next two weeks.


Table of Contents | Details |
------- |----------|
**Rewards**| What are the rewards and assessment criteria|
**Rules**| Who can participate|
**Targets**|What's in scope, out of scope, and examples of both|
**Details of Deployed Campaigns and Contracts** |Information on the honey pot campaign contracts|
**FAQ**|
**Legal**|
**Join the Mailing List** | Receive updates on bug bounties |

##Rewards

Paid out **Rewards** in ether are guided by the **Severity** category and the **Quality** of the submission, determined at the sole discretion of WeiFund.

* Critical: Up to $5,000
* High: Up to $3,000
* Medium: Up to $2,000
* Low: Up to $400
* Note: Up to $100

**Severity** is calculated according to [OWASP](https://www.owasp.org/index.php/OWASP_Risk_Rating_Methodology)’s risk model:

![Severity Chart](/assets/severity.png?raw=true "")

**Quality** of the submission includes (but not limited to):

* Quality of Description, Attack Scenario & Components: Clear and well-written descriptions will receive higher rewards.
* Quality of Reproduction: Include test code, scripts and detailed instructions. The easier it is for us to reproduce and verify the vulnerability, the higher the reward.
* Quality of Fix: Higher rewards are paid for submissions with clear instructions to fix the vulnerability.

Beyond monetary rewards, every bounty hunter is also eligible for being listed on our website and Github for recognition.

##Rules

* Issues that have already been submitted by another user or are already known to WeiFund are not eligible for bounty rewards
* Public disclosure of a vulnerability without WeiFund's prior consent results in ineligibility for a bounty
* ConsenSys' employees and all other people paid by ConsenSys, directly or indirectly, are not eligible for rewards
* Determinations of eligibility, award, and all terms related to an award are at the sole and final discretion of WeiFund. Decisions are guided by the submision's Impact, Likelihood and Quality

##Targets

### In scope:

* **Smart Contracts**: https://github.com/weifund/weifund-contracts/tree/develop/src/contracts
* **dApp browser code**: https://github.com/weifund/weifund-dapp-basic
* **Light Wallet**: https://github.com/ConsenSys/eth-lightwallet/tree/bdaa1e86134a0c3dddd423ebfc1b588837715d01/lib
* **Web3 Provider**: https://github.com/ConsenSys/hooked-web3-provider/blob/3ae3a4846cb56a9027696c97db6d6e19a9694c1c/app/hooked-web3-provider.es6
* **Multisig-Wallet**: https://github.com/ConsenSys/MultiSigWallet

**Examples of what's in scope** 

* Being able to obtain more tokens than expected
* Being able to obtain tokens from someone without their permission
* Bugs that lead to loss or theft of ether
* Bugs causing a transaction to be sent that was different from what user confirmed: for example, user transfers 10 ether in the UI, but exactly 10 wasn't transferred.
* Bugs that could lead to the direct loss of funds such as paying out to non-intended payout beneficiaries
* Bugs that lead to tokens being claimed before they should be
* Bugs that lead to the wrong amount of funds being refunded when a campaign is not successful


### Out of scope:

* Bugs related to Internet Explorer and browser-based issues
* All browser rendering bugs that don't affect the display of critical information
* Most user experience improvements on the frontend
* WeiFund's website: WeiFund.io
* Attacks via social engineering


**Examples of what's out of scope**

* Most user experience improvements on the frontend, for example some part of the website doesn't update unless the page is refreshed

##Details of Deployed Campaigns and Contracts

The campaigns will be on Ethereum’s Main Net and be constructed using our smart contract templates: two “Standard Campaigns” with “Enhancer Contracts” that issue tokens for each contribution. The **Fail Token** campaign will have a funding goal of 10,000 ether and the **Success Token** campaign will have a funding goal of 150 ether with a funding cap of 5000 ether. 

The Fail Token campaign will fail in raising the required funds and will refund all of its contributors. 

The Success Token campaign will succeed, and the tokens will be frozen for a limited time before being unfrozen and distributed. The ether funds in the Success Token campaign contract will be sent to a multisig beneficiary.

### Bug Bounty Fail Token Campaign

The following section describes the parameters of the campaign which will fail to reach its fundraising goal.

#### Contract Addresses

* __Campaign__: 0x0a6794fb71a4f567e6eb432ade293db7faf4b8d8
* __Enhancer__: 0xb1d393bbf102e60b62f53de35a9a107d9cb06b74
* __Multisig Wallet__: 0x850b2ecd566748c04b51d7effd3d27a8155b5879
* __Issued Token__: 0x2fce5b93ee7ee3ba5707112d7b4d34edadad0930


#### Standard Campaign Contract

* __Name__: Fail Token Campaign
* __Funding Goal__: 10,000 ETH
* __Funding Cap__: 20,000 ETH
* __Expiry__: 14 days (Block #3127930)
* __Beneficiary__: Multisig Wallet

#### Enhancer Contract

The campaign token is issued by the Model1Enhancer contract, which is used to issue tokens against a linear price and solid cap, it has the following parameters:

* __Token cap__: 160,000
* __Token price__: 0.125 ETH
* __Freeze period__: 16 days (Block #3127941)

#### Issued Token Contract

* __Name__: Fail Tokens
* __Symbol__: FT
* __Freeze period__: None
* __Decimals__: 2


### Bug Bounty Success Token Campaign

The following section describes the parameters of the campaign which will succeed in reaching its fundraising goal.

#### Contract Addresses

* __Campaign__: 0x3dc95a72717a1f27657c3b7ef060a8f3f68e0be4
* __Enhancer__: 0x725cfbffab60e77b8ea38c870c75b78efed50a51
* __Multisig Wallet__: 0x0489dc264e4188557d85db716cc6150e61c6491c
* __Issued Token__: 0xea42a626bacfe7db13fa5f8cd0568bf2b67f52d7

#### StandardCampaign Contract

* __Name__: Success Token Campaign
* __Funding Goal__: 150 ETH
* __Funding Cap__: 5000 ETH
* __Expiry__: 14 days (Block #3127966)
* __Beneficiary__: Multisig Wallet

#### Enhancer Contract

The campaign token is issued by the Model1Enhancer contract, which is used to issue tokens against a linear price and solid cap, it has the following parameters:

* __Token cap__: 40000
* __Token price__: 0.125 ETH
* __Freeze period__: 16 days (Block #3127973)

#### Issued Token Contract

* __Name__: Success Tokens
* __Symbol__: ST
* __Freeze period__: None
* __Decimals__: 10

### Shared Services

Both campaigns share a set of service contracts. 

* __Campaign Registry__: 0x16f771d64556d52cdef433ca96c696861317956e
* __Data Registry__: 0x7c17b1e6b4578152901c54d05b0464611bcb517c
* __Wallet Factory__: x4a176d9335f4f8e07e007ac5d3b3e72335cd9bb0
* __Token Factory__: 0xb455014982ed2b280b72f2228381b8f428373646
* __Enhancer Factory__: 0x55c5afdfc5dde98052ef1874ba6af273f45f0280
* __Campaign Factory__: 0x32234de40715073c70bf83415096e9e9265b6878


##FAQ

###What should a good vulnerability submission look like?

Here is an example of a real issue which was previously identified

**Description**: The enhancer stage can become out of sync with the campaign in method notate

**Attack Scenario**: The enhancer becomes out of sync, and a contribution can be made past the funding cap. Thus causing unwanted contribution.

**Components**: weifund-contracts/src/contracts/Model1Enhancer.sol and weifund-contracts/src/contracts/StandardCampaign.sol

**Reproduction**: Deploy campaign contracts in 'wafr' environment. Contribute to the point of the funding cap. Then log around the funding cap to reproduce.

**Details**: Any other details not covered. Can also contain links to GitHub Gists, repos containing code samples, etc.

**Fix**: Remove 'stage()' modifier from 'notate' method.

###Is the bug bounty program time limited?

February 4th 2017 11:59PM EST is the deadline for submissions.

###How are bounties paid out?

Rewards are paid out in ether after the submission has been validated. Local laws may require us to ask for proof of your identity. In addition, we will need your ether address.

###I reported an issue / vulnerability but have not received a response

We review and respond to submissions as fast as possible. Please email us mail@weifund.io if you have not received a response within three business days.

###I want to be anonymous

Submitting anonymously is fine, but may make you ineligible for rewards. To be eligible, we may require your real name and basic identifying information as necessary to comply with the law.

###What does Recognition mean?

Every bounty hunter who found a vulnerability or issue is eligible to be listed on our website.

###I have further questions

Email us at mail@weifund.io

##Legal

The bug bounty program is an experimental and discretionary rewards program for our active WeiFund community to encourage and reward those who are helping to improve the platform. It is not a competition. You should know that we can cancel the program at any time, and awards are at the sole discretion of WeiFund. The maximum rewards are subject to change without prior notice. In addition, we are not able to issue awards to individuals who are on sanctions lists or who are in countries on sanctions lists (e.g. North Korea, Iran, etc). You are responsible for all taxes. All awards are subject to applicable law. Your testing must not violate any law or compromise any data that is not yours. If you comply with the policy when reporting a security issue to us, we will not initiate a lawsuit or law enforcement investigation against you in response to your report. To be eligible for a reward, you must: 1. Give us reasonable time to investigate and mitigate an issue you report before making public any information about the report or sharing such information with others. 2. Avoid privacy violations and disruptions to others, including (but not limited to) destruction of data and interruption or degradation of our services. 3. Not exploit a security issue you discover for any reason (This includes demonstrating additional risk, such as attempted compromise of sensitive data or probing for additional issues). We will be using live Ethereum Main Net addresses. Please do not send ether (ETH) to the campaign addresses. WeiFund will not be held accountable for any ether (ETH) sent to the address, and is not held responsible for return of any funds.

For more information, please contact us at mail@weifund.io

##Mailing List

You can join the WeiFund Bounty Hunters [mailing list here](http://weifund.io/#bugBounty).
