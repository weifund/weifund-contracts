/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "factories/StandardCampaignFactory.sol";
import "campaigns/StandardCampaign.sol";

contract TestStandardCampaignFactory is Test {
  StandardCampaignFactory target;

  /// @dev deploy the factory, use it in the tests
  function setup() {
    target = new StandardCampaignFactory();
  }

  /// @dev test valid deployment, make sure all registry information is valid
  function test_validDeployment() {
    StandardCampaign campaign = StandardCampaign(address(target.createStandardCampaign(
      "Nick",
      (block.number + 1000),
      45000,
      4700000,
      address(this),
      address(target))));
    assertEq(campaign.expiry(), uint(block.number + 1000));
    assertEq(campaign.beneficiary(), address(this));
    assertEq(campaign.enhancer(), address(target));
    assertEq(campaign.fundingGoal(), uint(45000));
    assertEq(campaign.fundingCap(), uint(4700000));
  }
}
