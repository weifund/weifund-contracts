/*
This file is part of WeiFund.
*/

/*
Standard enhanced campaign for WeiFund. A generic crowdsale mechanism for
issuing and dispersing digital assets on Ethereum.
*/

pragma solidity ^0.4.4;

/*
Interfaces
*/
import "campaigns/Campaign.sol";
import "enhancers/Enhancer.sol";

/*
Specified Contracts
*/
import "utils/Owned.sol";
import "claims/BalanceClaim.sol";


/// @title Standard Campaign -- enables generic crowdsales that disperse digital assets
/// @author Nick Dodson <nick.dodson@consensys.net>
contract StandardCampaign is Owned, Campaign {
  // the three possible states
  enum Stages {
    CrowdfundOperational,
    CrowdfundFailure,
    CrowdfundSuccess
  }

  // the campaign state machine enforcement
  modifier atStage(Stages _expectedStage) {
    // if the current state does not equal the expected one, throw
    if (stage() != uint256(_expectedStage)) {
      throw;
    } else {
      // continue with state changing operations
      _;
    }
  }

  // if the contribution is valid, then carry on with state changing operations
  // notate the contribution with the enhancer, if the notation method
  // returns true, then trigger an early success (e.g. token cap reached)
  modifier validContribution() {
    // if the msg value is zero or amount raised plus the curent message value
    // is greater than the funding cap, then throw error
    if (msg.value == 0
      || amountRaised + msg.value > fundingCap
      || amountRaised + msg.value < amountRaised) {
      throw;
    } else {
      // carry on with state changing operations
      _;
    }
  }

  // if the contribution is a valid refund claim, then carry on with state
  // changing operations
  modifier validRefundClaim(uint256 _contributionID) {
    // get the contribution data for the refund
    Contribution refundContribution = contributions[_contributionID];

    // if the refund has already been claimed or the refund sender is not the
    // current message sender, throw error
    if(refundsClaimed[_contributionID] == true // the refund for this contribution is claimed
      || refundContribution.sender != msg.sender){ // the contribution sender is not the msg.sender
      throw;
    } else {
      // all is good, carry on with state changing operations
      _;
    }
  }

  // only the beneficiary can use the method with this modifier
  modifier onlybeneficiary() {
    if (msg.sender != beneficiary) {
      throw;
    } else {
      _;
    }
  }

  // allow for fallback function to be used to make contributions
  function () public payable {
    contributeMsgValue(defaultAmounts);
  }

  // the current campaign stage
  function stage() public constant returns (uint256) {
    // if current time is less than the expiry, the crowdfund is operational
    if (block.number < expiry
      && earlySuccess == false
      && amountRaised < fundingCap) {
      return uint256(Stages.CrowdfundOperational);

    // if n >= e and aR < fG then the crowdfund is a failure
    } else if(block.number >= expiry
      && earlySuccess == false
      && amountRaised < fundingGoal) {
      return uint256(Stages.CrowdfundFailure);

    // if n >= e and aR >= fG or aR >= fC or early success triggered
    // then the crowdfund is a success (enhancers can trigger early success)
    // early success is generally used for TokenCap enforcement
    } else if((block.number >= expiry && amountRaised >= fundingGoal)
      || earlySuccess == true
      || amountRaised >= fundingCap) {
      return uint256(Stages.CrowdfundSuccess);
    }
  }

  // contribute message value if the contribution is valid and the campaign
  // is in stage operational, allow for complex amounts to be transacted
  function contributeMsgValue(uint256[] _amounts)
    public // anyone can attempt to use this method
    payable // the method is payable and can accept ether
    atStage(Stages.CrowdfundOperational) // must be at stage operational, done before validContribution
    validContribution() // contribution must be valid, stage check done first
    returns (uint256 contributionID) {
    // increase contributions array length by 1, set as contribution ID
    contributionID = contributions.length++;

    // store contribution data in the contributions array
    contributions[contributionID] = Contribution({
        sender: msg.sender,
        value: msg.value,
        created: block.number
    });

    // add the contribution ID to that senders address
    contributionsBySender[msg.sender].push(contributionID);

    // increase the amount raised by the message value
    amountRaised += msg.value;

    // fire the contribution made event
    ContributionMade(msg.sender);

    // notate the contribution with the campaign enhancer, if the notation
    // method returns true, then trigger an early success
    // the enhancer is treated as malicious here, and is thus wrapped in a
    // conditional for saftey, note the enhancer may throw as well
    if (enhancer.notate(msg.sender, msg.value, block.number, _amounts)) {
      // set early success to true, note, it cannot be reversed once set to true
      // also validContribution must be after atStage modifier
      // so that early success is triggered after stage check, not before
      // early success is used to trigger an early campaign success before the funding
      // cap is reached. This is generally used for things like hitting the token cap
      earlySuccess = true;
    }
  }

  // payout the current balance to the beneficiary, if the crowdfund is in
  // stage success
  function payoutToBeneficiary() public onlybeneficiary() {
    // additionally trigger early success, this will force the Success state
    // forcing the success state keeps the contract state machine rigid
    // and ensures other third-party contracts that look to this state
    // that this contract is in state success
    earlySuccess = true;

    // send funds to the benerifiary
    if (!beneficiary.send(this.balance)) {
      throw;
    } else {
      // fire the BeneficiaryPayoutClaimed event
      BeneficiaryPayoutClaimed(beneficiary);
    }
  }

  // claim refund owed if you are a contributor and the campaign is in stage
  // failure. Only valid claims will be fulfilled.
  // will return the balance claim address where funds can be picked up by
  // contributor. A BalanceClaim is used to further prevent re-entrancy.
  function claimRefundOwed(uint256 _contributionID)
    public
    atStage(Stages.CrowdfundFailure) // in stage failure
    validRefundClaim(_contributionID) // the claim is a valid refund claim
    returns (address balanceClaim) { // return the balance claim address
    // set claimed to true right away
    refundsClaimed[_contributionID] = true;

    // get the contribution data for that contribution ID
    Contribution refundContribution = contributions[_contributionID];

    // send funds to the newly created balance claim contract
    balanceClaim = address(new BalanceClaim(refundContribution.sender));

    // set refunds claim address
    refundClaimAddress[_contributionID] = balanceClaim;

    // send funds to the newly created balance claim contract
    if (!balanceClaim.send(refundContribution.value)) {
      throw;
    }

    // fire the refund payed out event
    RefundPayoutClaimed(balanceClaim, refundContribution.value);
  }

  // the total number of valid contributions made to this campaign
  function totalContributions() public constant returns (uint256 amount) {
    return uint256(contributions.length);
  }

  // get the total number of contributions made a sender
  function totalContributionsBySender(address _sender)
    public
    constant
    returns (uint256 amount) {
    return uint256(contributionsBySender[_sender].length);
  }

  // the contract constructor
  function StandardCampaign(string _name,
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap,
    address _beneficiary,
    address _owner,
    address _enhancer) public {
    // set the campaign name
    name = _name;

    // the campaign expiry in blocks
    expiry = _expiry;

    // the funding goal in wei
    fundingGoal = _fundingGoal;

    // the campaign funding cap in wei
    fundingCap = _fundingCap;

    // the beneficiary address
    beneficiary = _beneficiary;

    // the owner or operator of the campaign
    owner = _owner;

    // the time the campaign was created
    created = block.number;

    // the campaign enhancer contract
    enhancer = Enhancer(_enhancer);
  }

  // the Contribution data structure
  struct Contribution {
    // the contribution sender
    address sender;

    // the value of the contribution
    uint256 value;

    // the time the contribution was created
    uint256 created;
  }

  // default amounts used
  uint256[] defaultAmounts;

  // campaign enhancer, usually for token notation
  Enhancer public enhancer;

  // the early success bool, used for triggering early success
  bool public earlySuccess;

  // the operator of the campaign
  address public owner;

  // the minimum amount of funds needed to be a success after expiry (in wei)
  uint256 public fundingGoal;

  // the maximum amount of funds that can be raised (in wei)
  uint256 public fundingCap;

  // the total amount raised by this campaign (in wei)
  uint256 public amountRaised;

  // the current campaign expiry (future block number)
  uint256 public expiry;

  // the time at which the campaign was created (in UNIX timestamp)
  uint256 public created;

  // the beneficiary of the funds raised, if the campaign is a success
  address public beneficiary;

  // the contributions data store, where all contributions are notated
  Contribution[] public contributions;

  // all contribution ID's of a specific sender
  mapping(address => uint256[]) public contributionsBySender;

  // the refund BalanceClaim address of a specific refund claim
  // maps the (contribution ID => refund claim address)
  mapping(uint256 => address) public refundClaimAddress;

  // maps the contribution ID to a bool (has the refund been claimed for this
  // contribution)
  mapping(uint256 => bool) public refundsClaimed;

  // the human readable name of the Campaign, for metadata
  string public name;

  // the contract version number, if any
  string constant public version = "0.1.0";

  // the contribution method ABI as a string, written in standard solidity
  // ABI format, this is generally used so that UI's can understand the campaign
  string constant public contributeMethodABI = "contributeMsgValue(uint256[]):(uint256)";

  // the payout to beneficiary ABI, written in standard solidity ABI format
  string constant public payoutMethodABI = "payoutToBeneficiary()";

  // the refund method ABI, written in standard solidity ABI format
  string constant public refundMethodABI = "claimRefundOwed(uint256):(address)";
}
