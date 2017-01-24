/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "utils/Owned.sol";
import "registries/CampaignRegistry.sol";

contract dummy {}

contract OwnedCampaign is Owned {
  function OwnedCampaign() {
    owner = msg.sender;
  }
}

contract CampaignRegistryUser {
  function () payable {}

  function makeCampaign() returns (address) {
    return address(new OwnedCampaign());
  }

  function register (address _campaign, address _interface, address _registry) returns (uint256){
    return CampaignRegistry(_registry).register(_campaign, _interface);
  }
}

contract CampaignRegistryTest is Test {
    CampaignRegistry reg;
    CampaignRegistryUser a;
    CampaignRegistryUser b;
    CampaignRegistryUser c;

    function setup () {
      a = new CampaignRegistryUser ();
      b = new CampaignRegistryUser ();
      c = new CampaignRegistryUser ();
      if(!a.send(50000)){ throw; }
      if(!b.send(50000)){ throw; }
      if(!c.send(50000)){ throw; }
    }

    function beforeEach () {
      reg = new CampaignRegistry();
    }

    function test_deployedCorrect() {
      assertEq(reg.numCampaigns(), 0, "Should be zero");
    }

    function test_register () {
      address campaignA = address(a.makeCampaign());
      address abiA = address(new dummy());

      assertEq(reg.numCampaigns(), uint256(0));
      assertEq(a.register(campaignA, abiA, address(reg)), uint256(0));
      assertEq(reg.numCampaigns(), uint256(1), "Should be one");
      assertEq(reg.addressOf(0), campaignA);
      assertEq(reg.abiOf(0), abiA);
      assertEq(reg.idOf(campaignA), uint256(0));
      assertTrue(reg.registeredAt(0) > 0);
    }

    function test_registerThree (){

      address campaignA = address(a.makeCampaign());
      address abiA = address(new dummy());

      assertEq(reg.numCampaigns(), uint256(0), "Should be zero");
      assertEq(a.register(campaignA, abiA, address(reg)), uint256(0));
      assertEq(reg.numCampaigns(), uint256(1), "Should be one");
      assertEq(reg.addressOf(0), campaignA);
      assertEq(reg.abiOf(0), abiA);
      assertEq(reg.idOf(campaignA), uint256(0));
      assertTrue(reg.registeredAt(0) > 0);


      address campaignB = b.makeCampaign();
      address abiB = new dummy();

      assertEq(reg.numCampaigns(), uint256(1), "Should be one");
      assertEq(b.register(campaignB, abiB, address(reg)), uint256(1));
      assertEq(reg.numCampaigns(), uint256(2), "Should be two");
      assertEq(reg.addressOf(1), campaignB);
      assertEq(reg.abiOf(1), abiB);
      assertEq(reg.idOf(campaignB), uint256(1));
      assertTrue(reg.registeredAt(1) > 0);

      address campaignC = c.makeCampaign();
      address abiC = new dummy();

      assertEq(reg.numCampaigns(), uint256(2), "Should be two");
      assertEq(c.register(campaignC, abiC, address(reg)), uint256(2));
      assertEq(reg.numCampaigns(), uint256(3), "Should be three");
      assertEq(reg.addressOf(2), campaignC);
      assertEq(reg.abiOf(2), abiC);
      assertEq(reg.idOf(campaignC), uint256(2));
      assertTrue(reg.registeredAt(2) > 0);
    }

    function test_doubleRegThrow() {
      address campaign = a.makeCampaign();
      address abi = new dummy();

      assertEq(a.register(campaign, abi, address(reg)), uint256(0));
      assertEq(a.register(campaign, abi, address(reg)), uint256(0));
    }
}
