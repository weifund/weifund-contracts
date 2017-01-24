/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "enhancers/CampaignEnhancer.sol";
import "campaigns/StandardCampaign.sol";

contract CampaignEnhancerProxy is CampaignEnhancer {
  function CampaignEnhancerProxy() {
    owner = msg.sender;
  }

  function onlyCampaignMethod() onlycampaign() {
    something = true;
  }

  function onlyAtStageSuccess() atStage(Stages.CrowdfundSuccess) {
    something = true;
  }

  function onlyAtStageOperational() atStage(Stages.CrowdfundOperational) {
    something = true;
  }

  function onlyAtStageFailure() atStage(Stages.CrowdfundFailure) {
    something = true;
  }

  bool public something;
}

contract TestCampaignEnhancer is Test {
  CampaignEnhancerProxy target;
  StandardCampaign campaign;

  function setup() {
    target = new CampaignEnhancerProxy();
    campaign = new StandardCampaign("Test Campaign",
      block.number + 1000,
      2982734,
      98273466287,
      address(this),
      address(this),
      address(target));
  }

  function test_a1_setCampaign() {
    target.setCampaign(address(campaign));
    assertEq(target.campaign(), address(campaign));
  }

  function test_a2_invalidOnlyCampaign_shouldThrow() {
    target.onlyCampaignMethod();
  }

  function test_a2_validOperational() {
    target.onlyAtStageOperational();
  }

  function test_a2_invalidStageSuccess_shouldThrow() {
    target.onlyAtStageSuccess();
  }

  function test_a2_invalidStageFailure_shouldThrow() {
    target.onlyAtStageFailure();
  }
}
