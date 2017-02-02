pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "campaigns/StandardCampaign.sol";
import "campaigns/tests/CampaignUser.sol";
import "enhancers/EmptyEnhancer.sol";
import "claims/BalanceClaim.sol";
import "enhancers/Enhancer.sol";

// test that a campaign deploys properly
contract TestStandardCampaign_deployment is Test {
  CampaignUser user;
  uint[] testAmounts;

  function setup() {
    user = new CampaignUser();
    if (!user.send(45000000000)) {
      throw;
    }
  }

  // test that the campaign deploys properly
  function test_validCampaignDeployment_withFundingGoal() {
    StandardCampaign target = StandardCampaign(user.createStandardCampaign(
      (block.number + 1000),
      450000000));
    assertEq(target.expiry(), (block.number + 1000), "expirt should be right");
    assertEq(target.fundingGoal(), uint(450000000), "funding goal should be right");
  }

  // test campaign deploys properly without funding goal
  function test_validCampaignDeployment_withoutFundingGoal() {
    StandardCampaign target = StandardCampaign(user.createStandardCampaign(
      (block.number + 1000),
      0));
    assertEq(target.expiry(), (block.number + 1000), "expiry should be block.number + 1000");
    assertEq(target.fundingGoal(), uint256(0), "funding goal should be 0");
  }
}

contract EasyEnhancer is Enhancer {
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts)
    public
    returns (bool earlySuccess) {
    return earlySuccessVal;
  }

  function setEarlySuccess(bool val) {
    earlySuccessVal = val;
  }

  bool public earlySuccessVal;
}

contract TestStandardCampaign_stageSuccess_earlySuccessTriggered is Test {
  StandardCampaign target;
  CampaignUser user;
  EasyEnhancer enhancer;

  function setup() {
    enhancer = new EasyEnhancer();
    target = new StandardCampaign("Test Campaign",
      block.number + 23423,
      2423423,
      7445645647,
      address(this),
      address(this),
      address(enhancer));
    if(!user.send(5000000)) {
      throw;
    }
  }

  // check deployment
  function test_a0_deployment() {
    assertEq(target.fundingGoal(), 2423423, "funding goal is correct");
    assertEq(target.fundingCap(), 7445645647, "funding cap is correct");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  uint256[] defaultValues;

  // test a bunch of contributions
  function test_a1_contributions_increaseBlockBy243() {
    uint id = target.contributeMsgValue.value(1)(defaultValues);
    assertEq(target.totalContributions(), uint(1));
    assertEq(target.totalContributionsBySender(address(this)), uint(1));

    uint id2 = target.contributeMsgValue.value(23423)(defaultValues);
    assertEq(id2, uint(1), "contribution made");
    var (sender1, value1, created1) = target.contributions(id2);
    assertEq(sender1, address(this), "contribution addr is correct");
    assertEq(value1, 23423, "contribution value is correct");
    assertTrue(created1 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(2));
    assertEq(target.totalContributionsBySender(address(this)), uint(2));

    uint id3 = target.contributeMsgValue.value(345)(defaultValues);
    assertEq(target.totalContributions(), uint(3));
    assertEq(target.totalContributionsBySender(address(this)), uint(3));

    uint id4 = target.contributeMsgValue.value(96796)(defaultValues);
    assertEq(target.totalContributions(), uint(4));
    assertEq(target.totalContributionsBySender(address(this)), uint(4));

    assertEq(target.amountRaised(), uint(1 + 23423 + 345 + 96796), "amount raised is right");
    assertEq(target.amountRaised(), target.balance, "amount raised is balance");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  // test a bunch of contributions
  function test_a2_contributions_increaseBlockBy2000() {
    uint id5 = target.contributeMsgValue.value(1)(defaultValues);
    assertEq(target.totalContributions(), uint(5));
    assertEq(target.totalContributionsBySender(address(this)), uint(5));

    uint id6 = target.contributeMsgValue.value(34)(defaultValues);
    assertEq(id6, uint(5), "contribution made");
    var (sender1, value1, created1) = target.contributions(id6);
    assertEq(sender1, address(this), "contribution addr is correct");
    assertEq(value1, 34, "contribution value is correct");
    assertTrue(created1 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(6));
    assertEq(target.totalContributionsBySender(address(this)), uint(6));

    uint id7 = target.contributeMsgValue.value(34533)(defaultValues);
    assertEq(target.totalContributions(), uint(7));
    assertEq(target.totalContributionsBySender(address(this)), uint(7));

    uint id8 = target.contributeMsgValue.value(4646)(defaultValues);
    assertEq(target.totalContributions(), uint(8));
    assertEq(target.totalContributionsBySender(address(this)), uint(8));

    assertEq(target.amountRaised(), uint(uint(1 + 23423 + 345 + 96796)
      + uint(1 + 34 + 34533 + 4646)), "amount raised is right");
    assertEq(target.amountRaised(), target.balance, "amount raised is balance");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  // make final contribution
  function test_a3_triggerEarlySuccess() {
    enhancer.setEarlySuccess(true);
    assertEq(enhancer.notate(address(this), 234, block.number, defaultValues), true, "notate should be true");
    assertEq(enhancer.earlySuccessVal(), true, "enhancer early success");
    uint id9 = target.contributeMsgValue.value(34)(defaultValues);
    assertEq(target.earlySuccess(), true, "target early success");
    assertEq(target.totalContributions(), uint(9));
    assertEq(target.totalContributionsBySender(address(this)), uint(9));
    assertEq(uint(target.stage()), uint(2), "stage is set to success");
  }

  // make invalid refund attempt
  function test_a4_invalidRefundAttempt_shouldThrow() {
    target.claimRefundOwed(0);
  }

  // make invalid refund attempt
  function test_a4_invalidRefundAttempt2_shouldThrow() {
    target.claimRefundOwed(4);
  }

  // make invalid refund attempt
  function test_a4_invalidRefundAttempt3_shouldThrow() {
    target.claimRefundOwed(8);
  }

  // make invalid refund attempt
  function test_a4_invalidPayoutAttempt_shouldThrow() {
    user.payoutToBeneficiary(address(target));
  }

  // make invalid refund attempt
  function test_a4_invalidContribution_shouldThrow() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  // make invalid refund attempt
  function test_a4_invalidContribution2_shouldThrow() {
    target.contributeMsgValue.value(3245)(defaultValues);
  }

  // make invalid refund attempt
  function test_a4_invalidContribution3_shouldThrow() {
    if (!target.call.value(23487)()) {
      throw;
    }
  }

  // make invalid refund attempt
  function test_a4_invalidContribution4_shouldThrow() {
    if (!target.call.value(0)()) {
      throw;
    }
  }

  // make invalid refund attempt
  function test_a4_invalidContribution5_shouldThrow() {
    target.contributeMsgValue.value(6445665723)(defaultValues);
  }

  // make payout to beneficiary
  function test_a5_validPayoutToBeneficiary() {
    uint prevBalance = this.balance;
    uint campBalance = target.balance;
    target.payoutToBeneficiary(true);
    assertEq(target.fundingGoal(), 2423423, "funding goal is correct");
    assertEq(target.fundingCap(), 7445645647, "funding cap is correct");
    assertEq(this.balance, prevBalance + campBalance, "balance increased");
    assertEq(target.balance, 0, "balance decrease of campaign");
    assertEq(uint(target.stage()), uint(2), "stage is set to success");
  }

  // test post expiry stage
  function test_a6_postExpiryStage_increaseBlockBy23425() {
    assertEq(uint(target.stage()), uint(2), "stage is set to success");
  }
}


contract TestStandardCampaign_stageSuccess_fundingCapReached is Test {
  StandardCampaign target;
  CampaignUser user;

  function setup() {
    target = new StandardCampaign("Test Campaign",
      block.number + 2342,
      224455,
      644566573,
      address(this),
      address(this),
      address(new EmptyEnhancer()));
    if(!user.send(5000000)) {
      throw;
    }
  }

  // check deployment
  function test_a0_deployment() {
    assertEq(target.fundingGoal(), 224455, "funding goal is correct");
    assertEq(target.fundingCap(), 644566573, "funding cap is correct");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  uint256[] defaultValues;

  // test a bunch of contributions
  function test_a1_contributions_increaseBlockBy243() {
    uint id = target.contributeMsgValue.value(1)(defaultValues);
    assertEq(target.totalContributions(), uint(1));
    assertEq(target.totalContributionsBySender(address(this)), uint(1));

    uint id2 = target.contributeMsgValue.value(23423)(defaultValues);
    assertEq(id2, uint(1), "contribution made");
    var (sender1, value1, created1) = target.contributions(id2);
    assertEq(sender1, address(this), "contribution addr is correct");
    assertEq(value1, 23423, "contribution value is correct");
    assertTrue(created1 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(2));
    assertEq(target.totalContributionsBySender(address(this)), uint(2));

    uint id3 = target.contributeMsgValue.value(345)(defaultValues);
    assertEq(target.totalContributions(), uint(3));
    assertEq(target.totalContributionsBySender(address(this)), uint(3));

    uint id4 = target.contributeMsgValue.value(96796)(defaultValues);
    assertEq(target.totalContributions(), uint(4));
    assertEq(target.totalContributionsBySender(address(this)), uint(4));

    assertEq(target.amountRaised(), uint(1 + 23423 + 345 + 96796), "amount raised is right");
    assertEq(target.amountRaised(), target.balance, "amount raised is balance");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  // test a bunch of contributions
  function test_a2_contributions_increaseBlockBy1000() {
    uint id5 = target.contributeMsgValue.value(1)(defaultValues);
    assertEq(target.totalContributions(), uint(5));
    assertEq(target.totalContributionsBySender(address(this)), uint(5));

    uint id6 = target.contributeMsgValue.value(34)(defaultValues);
    assertEq(id6, uint(5), "contribution made");
    var (sender1, value1, created1) = target.contributions(id6);
    assertEq(sender1, address(this), "contribution addr is correct");
    assertEq(value1, 34, "contribution value is correct");
    assertTrue(created1 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(6));
    assertEq(target.totalContributionsBySender(address(this)), uint(6));

    uint id7 = target.contributeMsgValue.value(34533)(defaultValues);
    assertEq(target.totalContributions(), uint(7));
    assertEq(target.totalContributionsBySender(address(this)), uint(7));

    uint id8 = target.contributeMsgValue.value(4646)(defaultValues);
    assertEq(target.totalContributions(), uint(8));
    assertEq(target.totalContributionsBySender(address(this)), uint(8));

    assertEq(target.amountRaised(), uint(uint(1 + 23423 + 345 + 96796)
      + uint(1 + 34 + 34533 + 4646)), "amount raised is right");
    assertEq(target.amountRaised(), target.balance, "amount raised is balance");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  // make final contribution
  function test_a3_validContribution_fundingCap() {
    uint valueAmount = target.fundingCap() - target.amountRaised();
    uint id7 = target.contributeMsgValue.value(valueAmount)(defaultValues);

    assertEq(id7, uint(8), "contribution made");
    var (sender1, value1, created1) = target.contributions(id7);

    assertEq(sender1, address(this), "contribution addr is correct");
    assertEq(value1, valueAmount, "contribution value is correct");
    assertTrue(created1 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(9));
    assertEq(target.totalContributionsBySender(address(this)), uint(9));
    assertEq(target.amountRaised(), target.fundingCap(), "amount raised is right");
    assertEq(uint(target.stage()), uint(2), "stage is set to success");
  }

  // make invalid refund attempt
  function test_a4_invalidRefundAttempt_shouldThrow() {
    target.claimRefundOwed(0);
  }

  // make invalid refund attempt
  function test_a4_invalidRefundAttempt2_shouldThrow() {
    target.claimRefundOwed(4);
  }

  // make invalid refund attempt
  function test_a4_invalidRefundAttempt3_shouldThrow() {
    target.claimRefundOwed(8);
  }

  // make invalid refund attempt
  function test_a4_invalidPayoutAttempt_shouldThrow() {
    user.payoutToBeneficiary(address(target));
  }

  // make invalid refund attempt
  function test_a4_invalidContribution_shouldThrow() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  // make invalid refund attempt
  function test_a4_invalidContribution2_shouldThrow() {
    target.contributeMsgValue.value(3245)(defaultValues);
  }

  // make invalid refund attempt
  function test_a4_invalidContribution3_shouldThrow() {
    if (!target.call.value(23487)()) {
      throw;
    }
  }

  // make invalid refund attempt
  function test_a4_invalidContribution4_shouldThrow() {
    if (!target.call.value(0)()) {
      throw;
    }
  }

  // make invalid refund attempt
  function test_a4_invalidContribution5_shouldThrow() {
    target.contributeMsgValue.value(6445665723)(defaultValues);
  }
}


contract TestStandardCampaign_stageSuccess_goalReached is Test {
  StandardCampaign target;
  CampaignUser user;

  function setup() {
    target = new StandardCampaign("Test Campaign",
      block.number + 1000,
      897345,
      298347892,
      address(this),
      address(this),
      address(new EmptyEnhancer()));
    if(!user.send(5000000)) {
      throw;
    }
  }

  // check deployment
  function test_a0_deployment() {
    assertEq(target.fundingGoal(), 897345, "funding goal is correct");
    assertEq(target.fundingCap(), 298347892, "funding cap is correct");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  uint256[] defaultValues;

  // test a bunch of contributions
  function test_a1_contributions() {
    uint id = target.contributeMsgValue.value(1)(defaultValues);
    assertEq(target.totalContributions(), uint(1));
    assertEq(target.totalContributionsBySender(address(this)), uint(1));

    uint id2 = target.contributeMsgValue.value(233)(defaultValues);
    assertEq(id2, uint(1), "contribution made");
    var (sender1, value1, created1) = target.contributions(id2);
    assertEq(sender1, address(this), "contribution addr is correct");
    assertEq(value1, 233, "contribution value is correct");
    assertTrue(created1 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(2));
    assertEq(target.totalContributionsBySender(address(this)), uint(2));

    uint id3 = target.contributeMsgValue.value(21)(defaultValues);
    assertEq(target.totalContributions(), uint(3));
    assertEq(target.totalContributionsBySender(address(this)), uint(3));

    uint id4 = target.contributeMsgValue.value(897345)(defaultValues);
    assertEq(target.totalContributions(), uint(4));
    assertEq(target.totalContributionsBySender(address(this)), uint(4));
  }

  // goal is reached and past expiry, campaign success!
  function test_a2_increaseBlockBy1001_invalidContributionThrow() {
    target.contributeMsgValue.value(897345)(defaultValues);
  }

  // check invalid contributions
  function test_a3_increaseBlockBy21_invalidContributionThrow() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  // check invalid contributions
  function test_a3_increaseBlockBy21_overCap_invalidContributionThrow() {
    target.contributeMsgValue.value(2453453434)(defaultValues);
  }

  // check invalid payout attempt
  function test_a3_invalidBeneficiaryPayout_throw() {
    user.payoutToBeneficiary(address(target));
  }

  // check invalid refund attemtp
  function test_a3_invalidRefundAttempt_0_throw() {
    target.claimRefundOwed(0);
  }

  // check invalid refund attemtp
  function test_a3_invalidRefundAttempt_1_throw() {
    target.claimRefundOwed(1);
  }

  // check invalid refund attemtp
  function test_a3_invalidRefundAttempt_2_throw() {
    target.claimRefundOwed(2);
  }

  // uint
  function test_a4_valid_payoutToBeneficiary() {
    uint previousBalance = this.balance;
    target.payoutToBeneficiary(true);
    assertEq(target.balance, 0, "target balance is zero");
    assertEq(this.balance, previousBalance + uint(1 + 233 + 21 + 897345), "target balance is zero");
    assertEq(uint(target.stage()), uint(2), "stage is success");
    assertEq(target.totalContributions(), uint(4));
    assertEq(target.totalContributionsBySender(address(this)), uint(4));
  }

  // goal is reached and past expiry, campaign success!
  function test_c2_increaseBlockBy1001_invalidContributionThrow() {
    target.contributeMsgValue.value(897345)(defaultValues);
  }

  // check invalid contributions
  function test_c3_increaseBlockBy21_invalidContributionThrow() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  // check invalid contributions
  function test_c3_increaseBlockBy21_overCap_invalidContributionThrow() {
    target.contributeMsgValue.value(2453453434)(defaultValues);
  }

  // check invalid payout attempt
  function test_c3_invalidBeneficiaryPayout_throw() {
    user.payoutToBeneficiary(address(target));
  }

  // check invalid refund attemtp
  function test_c3_invalidRefundAttempt_0_throw() {
    target.claimRefundOwed(0);
  }

  // check invalid refund attemtp
  function test_c3_invalidRefundAttempt_1_throw() {
    target.claimRefundOwed(1);
  }

  // check invalid refund attemtp
  function test_c3_invalidRefundAttempt_2_throw() {
    target.claimRefundOwed(2);
  }
}

contract TestStandardCampaign_stageFailure is Test {
  StandardCampaign target;
  CampaignUser user;

  function setup() {
    target = new StandardCampaign("Test Campaign",
      block.number + 1000,
      47000,
      4700000,
      address(this),
      address(this),
      address(new EmptyEnhancer()));
    if(!user.send(5000000)) {
      throw;
    }
  }

  // check deployment
  function test_a0_deployment() {
    assertEq(target.fundingGoal(), 47000, "funding goal is correct");
    assertEq(target.fundingCap(), 4700000, "funding cap is correct");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  uint256[] defaultValues;

  // test a valid contribution
  function test_a1_validContribution_withValue() {
    uint id = target.contributeMsgValue.value(24234)(defaultValues);
    assertEq(id, uint(0), "contribution made");
    var (sender, value, created) = target.contributions(0);
    assertEq(sender, address(this), "contribution addr is correct");
    assertEq(value, 24234, "contribution value is correct");
    assertTrue(created > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(1));
    assertEq(target.totalContributionsBySender(address(this)), uint(1));
  }

  // test an invalid contribution past blocks by 10001
  function test_a2_validContribution_increaseBlockBy1001() {
    assertEq(block.number >= target.expiry(), true, "block num past expiry");
    assertEq(target.amountRaised() < target.fundingGoal(), true, "amount raised is less than funding goal");
  }

  // test an invalid contribution past blocks by 10001
  function test_a3_invalidContribution_throw() {
    target.contributeMsgValue.value(24234)(defaultValues);
  }

  // test invalid contribution value zero
  function test_a4_invalidContribution_zeroValue_throw() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  // test invalid beneficiary payout
  function test_a5_invalidBeneficiaryPayout_accessRestriction_throw() {
    user.payoutToBeneficiary(address(target));
  }

  // test stage balance
  function test_a6_testStageBalance() {
    assertEq(uint(target.balance), uint(24234));
    assertEq(target.totalContributions(), uint(1));
    assertEq(target.totalContributionsBySender(address(this)), uint(1));
  }

  // test valid refund
  function test_a7_validRefund() {
    uint previousBalance = this.balance;
    BalanceClaim claim = BalanceClaim(address(target.claimRefundOwed(0)));
    assertTrue(address(claim) != address(0), "address is filled");
    uint claimBalance = claim.balance;
    assertEq(claim.balance, uint(24234), "balance is valid");
    claim.claimBalance();
    assertEq(claim.balance, uint(0), "balance is valid");
    assertEq(this.balance, uint(previousBalance + claimBalance), "balance is increased");
  }

  // test invalid double refund
  function test_a8_invalidDoubleRefund_shouldThrow() {
    target.claimRefundOwed(0);
  }
}


contract TestStandardCampaign_stageOperational is Test {
  StandardCampaign target;
  CampaignUser user;

  function setup() {
    target = new StandardCampaign("Test Campaign",
      block.number + 1000,
      47000,
      4700000,
      address(this),
      address(this),
      address(new EmptyEnhancer()));
    if(!user.send(5000000)) {
      throw;
    }
  }

  function test_a0_deployment() {
    assertEq(target.fundingGoal(), 47000, "funding goal is correct");
    assertEq(target.fundingCap(), 4700000, "funding cap is correct");
    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  uint256[] defaultValues;

  function test_a1_validContribution_withValue() {
    uint id = target.contributeMsgValue.value(4500)(defaultValues);
    assertEq(id, uint(0), "contribution made");
    var (sender, value, created) = target.contributions(0);
    assertEq(sender, address(this), "contribution addr is correct");
    assertEq(value, 4500, "contribution value is correct");
    assertTrue(created > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(1));
    assertEq(target.totalContributionsBySender(address(this)), uint(1));

    uint id2 = target.contributeMsgValue.value(32413)(defaultValues);
    assertEq(id2, uint(1), "contribution made");
    var (sender2, value2, created2) = target.contributions(id2);
    assertEq(sender2, address(this), "contribution addr is correct");
    assertEq(value2, 32413, "contribution value is correct");
    assertTrue(created2 > 0, "contribution creation time is correct");
    assertEq(target.totalContributions(), uint(2));
    assertEq(target.totalContributionsBySender(address(this)), uint(2));

    assertEq(uint(target.stage()), uint(0), "stage is set to operational");
  }

  function test_aa1_invalidContribution_overFundingCap_throw() {
    target.contributeMsgValue.value(4700000)(defaultValues);
  }

  function test_a2_invalidContribution_withoutValue_throw() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  function test_a3_invalidContribution_withoutValueCall_throw() {
    if(!target.call.value(0)()){
      throw;
    }
  }

  function test_a4_attemptInvalidRefund_throw() {
    target.claimRefundOwed(0);
  }

  function test_a5_attemptInvalidRefund_throw() {
    target.claimRefundOwed(1);
  }

  function test_a6_attemptInvalidBeneficiaryPayout_throw() {
    user.payoutToBeneficiary(address(target));
  }

  function test_a7_validPanicBeneficiaryPayout() {
    uint initialBalance = this.balance;
    uint balanceInCampaign = target.balance;
    target.payoutToBeneficiary(true);
    assertEq(uint(target.stage()), uint(2), "stage is set to success");
    assertEq(uint(target.balance), uint(0), "balance is now zero");
    assertEq(uint(this.balance), uint(initialBalance + balanceInCampaign), "balance is increased");
  }

  function test_a8_invalidContribution_withoutValue_throw() {
    target.contributeMsgValue.value(0)(defaultValues);
  }

  function test_a9_invalidContribution_withoutValueCall_throw() {
    if(!target.call.value(0)()){
      throw;
    }
  }

  function test_b1_attemptInvalidRefund_throw() {
    target.claimRefundOwed(0);
  }

  function test_b2_attemptInvalidRefund_throw() {
    target.claimRefundOwed(1);
  }

  function test_b3_attemptInvalidBeneficiaryPayout_throw() {
    user.payoutToBeneficiary(address(target));
  }

  function test_b4_invalidContribution_withoutValue_throw() {
    target.contributeMsgValue.value(1232)(defaultValues);
  }
}
