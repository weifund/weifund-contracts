pragma solidity ^0.4.4;

import "campaigns/StandardCampaign.sol";
import "enhancers/EmptyEnhancer.sol";
import "claims/BalanceClaim.sol";

contract TokenClaim {
  function claim() {}
}

contract CampaignUser {
  function () payable {}

  function createStandardCampaign(
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap,
    address _beneficiary,
    address _enhancer) public returns (address) {
    return address(new StandardCampaign(
      "Test Campaign",
      _expiry,
      _fundingGoal,
      _fundingCap,
      _beneficiary,
      address(this),
      _enhancer));
  }

  function createStandardCampaign(
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap,
    address _beneficiary) public returns (address) {
    return address(new StandardCampaign(
      "Test Campaign",
      _expiry,
      _fundingGoal,
      _fundingCap,
      _beneficiary,
      address(this),
      address(new EmptyEnhancer())));
  }

  function createStandardCampaign(
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap) public returns (address) {
    return address(new StandardCampaign(
      "Test Campaign",
      _expiry,
      _fundingGoal,
      _fundingCap,
      address(this),
      address(this),
      address(new EmptyEnhancer())));
  }

  function createStandardCampaign(
    uint256 _expiry,
    uint256 _fundingGoal) public returns (address) {
    return address(new StandardCampaign(
      "Test Campaign",
      _expiry,
      _fundingGoal,
      450000000000000,
      address(this),
      address(this),
      address(new EmptyEnhancer())));
  }

  function createStandardCampaign(
    uint256 _expiry) public returns (address) {
    return address(new StandardCampaign(
      "Test Campaign",
      _expiry,
      450000000000,
      450000000000000,
      address(this),
      address(this),
      address(new EmptyEnhancer())));
  }

  function createStandardCampaign() public returns (address) {
    return address(new StandardCampaign(
      "Test Campaign",
      (now + 8 weeks),
      450000000000,
      450000000000000,
      address(this),
      address(this),
      address(new EmptyEnhancer())));
  }

  function getContributionByUser(address _campaign, uint _index) constant returns (
    address sender,
    uint256 value,
    uint256 created) {
    uint contributionID = StandardCampaign(_campaign).contributionsBySender(address(this), _index);
    var (cSender, cValue, cCreated) = StandardCampaign(_campaign).contributions(contributionID);
    sender = cSender;
    value = cValue;
    created = cCreated;
  }

  uint256[] defaultValues;

  function contributeMsgValue(address _campaign, uint256 _value)
    returns (uint256 _contributionID) {
    return StandardCampaign(_campaign).contributeMsgValue.gas(3000000).value(_value)(defaultValues);
  }

  function contributeMsgValue(address _campaign, uint256 _value, uint256[] _amounts)
    returns (uint256 _contributionID) {
    return StandardCampaign(_campaign).contributeMsgValue.gas(3000000).value(_value)(_amounts);
  }

  function contributeViaSend(address _campaign, uint256 _value) {
    if (!_campaign.send(_value)) {
      throw;
    }
  }

  function contributeViaCall(address _campaign, uint256 _value) {
    if (!_campaign.call.gas(3000000).value(_value)(bytes4(sha3("contributeMsgValue(uint256[]):(uint256)")))) {
      throw;
    }
  }

  function contributeViaCall(address _campaign, uint256 _value, uint256[] _amounts) {
    if (!_campaign.call.gas(3000000).value(_value)(bytes4(sha3("contributeMsgValue(uint256[]):(uint256)")), _amounts)) {
      throw;
    }
  }

  function contributeViaEmptyCall(address _campaign, uint256 _value) {
    if (!_campaign.call.gas(3000000).value(_value)()) {
      throw;
    }
  }

  function claimRefundOwed(address _campaign, uint256 _contributionID)
    public
    returns (address) {
    return address(StandardCampaign(_campaign).claimRefundOwed.gas(3000000)(_contributionID));
  }

  function claimRefundOwed(address _campaign, uint256 _contributionID, uint256 _value)
    public
    returns (address) {
    return address(StandardCampaign(_campaign).claimRefundOwed.gas(3000000)(_contributionID));
  }

  function claimAllRefundsOwed(address _campaign)
    public
    returns (address) {
    uint contributionID = StandardCampaign(_campaign).contributionsBySender(address(this), 0);
    return address(StandardCampaign(_campaign).claimRefundOwed.gas(3000000)(contributionID));
  }

  function payoutToBeneficiary(address _campaign) public {
    StandardCampaign(_campaign).payoutToBeneficiary.gas(3000000)();
  }

  function claimTokens(address _target) public {
    TokenClaim(_target).claim.gas(3000000)();
  }

  function claimBalance(address _balanceClaim) {
    BalanceClaim(_balanceClaim).claimBalance();
  }
}
