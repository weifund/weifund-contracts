/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "utils/Owned.sol";
import "registries/CampaignDataRegistry.sol";

contract TestCampaignOwned is Owned {
  function () payable {}

  function TestCampaignOwned(address _owner) {
    owner = _owner;
  }
}

contract TestCampaignDataRegistry is Owned, CampaignDataRegistry, Test {
  TestCampaignOwned target;

  function setup() {
    target = new TestCampaignOwned(address(msg.sender));
  }

  function test_0_register() {
    assertEq(target.owner(), address(msg.sender));
    register(address(target), "");
  }

  function test_0_invalidRegistration() {
  }

  function test_1_getData() {
    assertEq(storedData(address(target)), "");
  }
}
