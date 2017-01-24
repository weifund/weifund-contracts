/*
This file is part of WeiFund.
*/

/*
The campaign enhancer contract, used to design campaign enhancers for the
Enhanced standard campaigns.
*/

pragma solidity ^0.4.4;

import "utils/Owned.sol";
import "campaigns/Campaign.sol";
import "enhancers/Enhancer.sol";


/// @title Campaign enahncer contract for build campaign enhancers
/// @author Nick Dodson <nick.dodson@consensys.net>
contract CampaignEnhancer is Owned {
  enum Stages {
    CrowdfundOperational,
    CrowdfundFailure,
    CrowdfundSuccess
  }

  // only the campaign contract can pass
  modifier onlycampaign() {
    if (msg.sender != address(campaign)) {
      throw;
    } else {
      _;
    }
  }

  // checks the current campaign stage against an expected stage
  modifier atStage(Stages _expectedStage) {
    if (campaign.stage() != uint256(_expectedStage)) {
      throw;
    } else {
      _;
    }
  }

  /// @dev allows the owner to set the campaign address
  function setCampaign(address _campaign) onlyowner() public {
    if (campaign != address(0)) {
      throw;
    } else {
      campaign = Campaign(_campaign);
    }
  }

  // the campaign contract instance
  Campaign public campaign;
}
