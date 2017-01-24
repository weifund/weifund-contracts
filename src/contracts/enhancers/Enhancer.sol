/*
This file is part of WeiFund.
*/

/*
The enhancer interface for the CampaignEnhancer contract.
*/

pragma solidity ^0.4.4;


/// @title The campaign enhancer interface contract for build enhancer contracts.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Enhancer {
  /// @notice enables the setting of the campaign, if any
  /// @dev allow the owner to set the campaign
  function setCampaign(address _campaign) public {}

  /// @notice notate contribution
  /// @param _sender The address of the contribution sender
  /// @param _value The value of the contribution
  /// @param _blockNumber The block number of the contribution
  /// @param _amounts The specified contribution product amounts, if any
  /// @return Whether or not the campaign is an early success after this contribution
  /// @dev enables the notation of contribution data, and triggering of early success, if need be
  function notate(address _sender, uint256 _value, uint256 _blockNumber, uint256[] _amounts) public returns (bool earlySuccess) {}
}
