/*
This file is part of WeiFund.
*/

/*
A factory contract used for the generation and registration of WeiFund enhanced
standard campaign contracts.
*/

pragma solidity ^0.4.4;

import "registries/PrivateServiceRegistry.sol";
import "campaigns/StandardCampaign.sol";
import "enhancers/EmptyEnhancer.sol";


/// @title Enhanced Standard Campaign Factory - used to generate and register standard campaigns
/// @author Nick Dodson <nick.dodson@consensys.net>
contract StandardCampaignFactory is PrivateServiceRegistry {
  function createStandardCampaign(string _name,
    uint256 _expiry,
    uint256 _fundingGoal,
    uint256 _fundingCap,
    address _beneficiary,
    address _enhancer) public returns (address campaignAddress) {
    // create the new enhanced standard campaign
    campaignAddress = address(new StandardCampaign(_name,
      _expiry,
      _fundingGoal,
      _fundingCap,
      _beneficiary,
      msg.sender,
      _enhancer));

    // register the campaign address
    register(campaignAddress);
  }
}
