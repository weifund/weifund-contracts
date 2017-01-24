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

The campaigns will be on Ethereum’s Main Net and be constructed using our smart contract templates: two “Standard Campaigns” with “Enhancer Contracts” that issue tokens for each contribution. The **Fail Token** campaign will have a funding goal of 10,000 ether and the **Success Token** campaign will have a funding goal of 150 ether with a funding cap of 5000 ether. The Fail Token campaign will fail in raising the required funds and will refund all of its contributors. The Success Token campaign will succeed, and the tokens will be frozen for a limited time before being unfrozen and distributed. The ether funds in the Success Token campaign contract will be sent to a multisig beneficiary.

###Campaign1

* Name: Bug Bounty FailToken Campaign
* Contracts
    * IssuedToken(freezePeriod=???, name=FailToken, decimals=18, symbol=BBFT)
        * setIssuer(enhancer)
    * Model1Enhancer(tokenPrice=1 wei?, freezePeriod=???, token=token)
    * StandardCampaign(name=”FailToken Campaign”, expiry=???, fundingGoal=10,000 ether, beneficiary=multisig, enhancer=enhancer)
* Addresses
    * [main net addresses]
* Multisig Wallet

###Campaign2:

* Name: Bug Bounty SuccessToken Campaign
* Contracts
    * IssuedToken(freezePeriod=???, name=SuccessToken, decimals=18, symbol=BBST)
        * setIssuer(enhancer)
    * Model1Enhancer(tokenPrice=1 wei?, freezePeriod=0?, token=token)
    * StandardCampaign(name=”SuccessToken Campaign”, expiry=???, fundingGoal=150 ether, beneficiary=multisig, enhancer=enhancer)
* Addresses
    * [main net addresses]
* Beneficiary
    * Same as above

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
