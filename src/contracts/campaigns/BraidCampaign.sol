pragma solidity ^0.4.4;


import "utils/Owned.sol";
import "verifiers/OwnedVerifier.sol";
import "tokens/StandardToken.sol";

/*
A custom WeiFund compatable campaign for the Braid the Movie Ethereum campaign.
*/

contract BraidCampaign is Owned, StandardToken {
  modifier pastFreezeDate {
    // now must be greater than freeze date
    if (block.number >= freezePeriod) {
      _;
    } else {
      throw;
    }
  }

  function transfer(address _to, uint256 _value) pastFreezeDate public returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) pastFreezeDate public returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) pastFreezeDate public returns (bool success) {
    return super.approve(_spender, _value);
  }

  function () payable public {
    // allow fallback function.. contribute as normal
    contributeMsgValue(defaultAmounts);
  }

  function contributeMsgValue(uint256[] _amounts) payable public returns (uint256) {
    // the total tokens amount to be issued to the sender
    uint256 tokensOwed = (msg.value / price) * 10**9;

    // is the contribution valid and the campaign is not stopped
    // the contribution is made before campaign endDate, the sender is verified
    // the sender has contributed enough to receive one toke
    //  the tokens owed plus the tokens issued is less than the token cap
    if (earlySuccess == false
      && block.number < expiry
      && verifier.approved(msg.sender)
      && tokensOwed > 0
      && tokensOwed + tokensIssued <= tokenCap) {
      // raise the total amount raised by the message value
      amountRaised += msg.value;

      // increase the balance of the sender
      balances[msg.sender] += tokensOwed;

      // increase the total amount of contributions by 1 for record
      totalContributions += 1;

      // incease the total supply of tokens
      totalSupply += tokensOwed;

      // increase the total tokens issued by tokens owed
      tokensIssued += tokensOwed;

      if (!beneficiary.call.value(msg.value)()) {
        throw;
      }

      return totalContributions;
    } else {
      throw;
    }
  }

  function changePrice(uint256 _price) onlyowner() public {
    // set the price per token in wei
    price = _price;
  }

  function stopCampaign() onlyowner() public {
    // stop the campaign for good
    earlySuccess = true;
  }

  function stage() public constant returns (uint256) {
    // cosmetic stage function
    if (tokensIssued >= tokenCap
      || block.number >= expiry
      || earlySuccess) {
      // campaign has concluded
      return 2;
    } else {
      // campaign is operational
      return 0;
    }
  }

  function BraidCampaign(address[] _founders,
    uint256[] _founderBalances,
    address _beneficiary,
    address _verifier,
    uint256 _expiry,
    uint256 _tokenCap,
    uint256 _price,
    uint256 _freezePeriod) {
    beneficiary = _beneficiary;
    verifier = Verifier(_verifier);
    expiry = _expiry;
    tokenCap = _tokenCap;
    price = _price;
    freezePeriod = _freezePeriod;
    created = block.number;
    owner = _beneficiary;
    enhancer = address(this);
    token = address(this);

    // disperse initial tokens to the founders
    for(uint256 i = 0; i < _founders.length; i += 1) {
      // increase founder amount
      balances[_founders[i]] = _founderBalances[i];

      // increase total token supply by founder amount
      totalSupply += _founderBalances[i];
    }
  }

  // default amounts used
  uint256[] defaultAmounts;

  // the stop param, which can be triggered by the beneficiary to stop the campaign
  bool public earlySuccess;

  // campaign enhancer, usually for token notation
  address public token;

  // campaign enhancer, usually for token notation
  address public enhancer;

  // the beneficiary of the campaign, where money is sent directly
  address public beneficiary;

  // the verifier contract which determines if the sender is approved or not
  Verifier public verifier;

  // when the campaign was created
  uint256 public created;

  // the unfreeze date, at which tokens can be transferable
  uint256 public freezePeriod;

  // the total amount raised in wei
  uint256 public amountRaised;

  // the end date of the campaign in block number format
  uint256 public expiry;

  // the total amount of tokens issed
  uint256 public tokensIssued;

  // the total amount of tokens that can be issued
  uint256 public tokenCap;

  // the price per token in wei
  uint256 public price;

  // the total number of contributions
  uint256 public totalContributions;

  // the minimum amount of funds needed to be a success after expiry (in wei)
  uint256 constant public fundingGoal = 0;

  // the maximum amount of funds that can be raised (in wei)
  uint256 constant public fundingCap = 0;

  // the human readable name of the Campaign, for metadata
  string constant public name = "Braid Campaign Token";

  //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
  uint8 constant public decimals = 18;

   //An identifier: eg SBX
  string constant public symbol = "BRD";

   //human 0.1 standard. Just an arbitrary versioning scheme.
  string constant public version = "H0.1";

  // the contribution method ABI as a string, written in standard solidity
  // ABI format, this is generally used so that UI's can understand the campaign
  string constant public contributeMethodABI = "contributeMsgValue(uint256[]):(uint256)";

  // the claim method ABI, specified for this contract to claim tokens owed
  string public constant claimMethodABI = "";

  // the payout to beneficiary ABI, written in standard solidity ABI format
  string constant public payoutMethodABI = "";

  // the refund method ABI, written in standard solidity ABI format
  string constant public refundMethodABI = "";
}
