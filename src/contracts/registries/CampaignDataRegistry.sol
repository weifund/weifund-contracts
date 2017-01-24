/*
This file is part of WeiFund.
*/

/*
The campaign data registry contract is used to register IPFS hash data against
campaign ID's. Only the campaign owner (operator) can actually register the hashes.
Hashes can be registered multiple times (so that operators can update cosmetic data).
*/

pragma solidity ^0.4.4;

import "utils/Owned.sol";


/// @title Campaign Data Registry Interface - used to build campaign data registries
/// @author Nick Dodson <nick.dodson@consensys.net>
contract CampaignDataRegistryInterface {
  /// @notice call `register` to register your campaign with a specified data store
  /// @param _campaign the address of the crowdfunding campaign
  /// @param _data the data store of that campaign, potentially an ipfs hash
  function register(address _campaign, bytes _data) public;

  /// @notice call `storedDate` to retrieve data specified for a campaign address
  /// @param _campaign the address of the crowdfunding campaign
  /// @return the data stored in bytes
  function storedData(address _campaign) constant public returns (bytes dataStored);

  event CampaignDataRegistered(address _campaign);
}


/// @title Campaign Data Registry - used to register IPFS hashes against campaign addresses.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract CampaignDataRegistry is CampaignDataRegistryInterface {

  modifier senderIsCampaignOwner(address _campaign) {
    // if the owner of the campaign is the sender
    if (Owned(_campaign).owner() != msg.sender) {
      throw;
    }

    // otherwise, carry on with normal state changing logic
    _;
  }

  function register(address _campaign, bytes _data) senderIsCampaignOwner(_campaign) public {
    data[_campaign] = _data;
    CampaignDataRegistered(_campaign);
  }

  function storedData(address _campaign) constant public returns (bytes dataStored) {
    return data[_campaign];
  }

  mapping(address => bytes) data;
}
