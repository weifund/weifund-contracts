pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "campaigns/tests/CampaignUser.sol";
import "campaigns/StandardCampaign.sol";
import "enhancers/EmptyEnhancer.sol";

// test that the user can preform normal campaign tasks
contract TestCampaignUser is Test {
  CampaignUser user;

  function setup() {
    user = new CampaignUser();
    if (!user.send(50000000)) {
      throw;
    }
  }

  // test that the user can create enhanced campaign
  function test_enhancedCampaignCreation() {
    EnhancedStandardCampaign target = EnhancedStandardCampaign(user.createEnhancedStandardCampaign(
      (block.number + 1000),
      45000000,
      45000000000,
      address(user),
      address(new EmptyEnhancer())
    ));
    assertEq(target.expiry(), (block.number + 1000));
    assertEq(target.fundingGoal(), uint(45000000));
    assertEq(target.fundingCap(), uint(45000000000));
    assertEq(target.beneficiary(), address(user));
    assertEq(target.enhancer(), address(this));
  }


  uint[] testAmounts;

  // test that the user can contribute using api enhanced
  function test_contributeMsgValueWithAmounts() {
    EnhancedStandardCampaign target = EnhancedStandardCampaign(user.createEnhancedStandardCampaign(
      (block.number + 1000),
      45000000,
      45000000000,
      address(user),
      address(new EmptyEnhancer())
    ));
    user.contributeMsgValue(address(target), 4500, testAmounts);
    var (cSender, cValue, cCreated) = user.getContributionByUser(address(target), 0);
    assertEq(cSender, address(user));
    assertEq(cValue, uint(4500));
  }

  // test that the user can contribute using fallback
  function test_contributeViaSend_throw() {
    StandardCampaign target = StandardCampaign(user.createStandardCampaign(
      (block.number + 1000),
      45000000,
      45000000000,
      address(user)
    ));
    user.contributeViaSend(address(target), 4500);
    var (cSender, cValue, cCreated) = user.getContributionByUser(address(target), 0);
    assertEq(cSender, address(user));
    assertEq(cValue, uint(4500));
  }

  // test that the user can contribute using just call
  function test_contributeViaEmptyCall() {
    StandardCampaign target = StandardCampaign(user.createStandardCampaign(
      (block.number + 1000),
      45000000,
      45000000000,
      address(user)
    ));
    user.contributeViaEmptyCall(address(target), 4500);
    var (cSender, cValue, cCreated) = user.getContributionByUser(address(target), 0);
    assertEq(cSender, address(user));
    assertEq(cValue, uint(4500));
  }

  // test that the user can contribute using just call
  function test_contributeViaCall() {
    StandardCampaign target = StandardCampaign(user.createStandardCampaign(
      (block.number + 1000),
      45000000,
      45000000000,
      address(user)
    ));
    user.contributeViaCall(address(target), 4500);
    var (cSender, cValue, cCreated) = user.getContributionByUser(address(target), 0);
    assertEq(cSender, address(user));
    assertEq(cValue, uint(4500));
  }

  // test that the user can contribute using call with amounts
  function test_contributeViaCallAmounts() {
    StandardCampaign target = StandardCampaign(user.createStandardCampaign(
      (block.number + 1000),
      45000000,
      45000000000,
      address(user)
    ));
    user.contributeViaCall(address(target), 4500, testAmounts);
    var (cSender, cValue, cCreated) = user.getContributionByUser(address(target), 0);
    assertEq(cSender, address(user));
    assertEq(cValue, uint(4500));
  }

  // test that the user can contribute using call with amounts
  function test_payoutToBenficiary() {
  }

  // test that the user can contribute using call with amounts
  function test_claimBeneficiary() {
  }
}
