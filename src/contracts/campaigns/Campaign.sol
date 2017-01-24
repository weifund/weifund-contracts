/*
This file is part of WeiFund.
*/

/*
The core campaign contract interface. Used across all WeiFund standard campaign
contracts.
*/

pragma solidity ^0.4.4;


/// @title Campaign contract interface for WeiFund standard campaigns
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Campaign {
  /// @notice the creater and operator of the campaign
  /// @return the Ethereum standard account address of the owner specified
  function owner() public constant returns(address) {}

  /// @notice the campaign interface version
  /// @return the version metadata
  function version() public constant returns(string) {}

  /// @notice the campaign name
  /// @return contractual metadata which specifies the campaign name as a string
  function name() public constant returns(string) {}

  /// @notice use to determine the contribution method abi/structure
  /// @return will return a string that is the exact contributeMethodABI
  function contributeMethodABI() public constant returns(string) {}

  /// @notice use to determine the contribution method abi
  /// @return will return a string that is the exact contributeMethodABI
  function refundMethodABI() public constant returns(string) {}

  /// @notice use to determine the contribution method abi
  /// @return will return a string that is the exact contributeMethodABI
  function payoutMethodABI() public constant returns(string) {}

  /// @notice use to determine the beneficiary destination for the campaign
  /// @return the beneficiary address that will receive the campaign payout
  function beneficiary() public constant returns(address) {}

  /// @notice the block number at which the campaign fails or succeeds
  /// @return the uint block number at which time the campaign expires
  function expiry() public constant returns(uint256 blockNumber) {}

  /// @notice the goal the campaign must reach in order for it to succeed
  /// @return the campaign funding goal specified in wei as a uint256
  function fundingGoal() public constant returns(uint256 amount) {}

  /// @notice the maximum funding amount for this campaign
  /// @return the campaign funding cap specified in wei as a uint256
  function fundingCap() public constant returns(uint256 amount) {}

  /// @notice the goal the campaign must reach in order for it to succeed
  /// @return the campaign funding goal specified in wei as a uint256
  function amountRaised() public constant returns(uint256 amount) {}

  /// @notice the block number that the campaign was created
  /// @return the campaign start block specified as a block number, uint256
  function created() public constant returns(uint256 timestamp) {}

  /// @notice the current stage the campaign is in
  /// @return the campaign stage the campaign is in with uint256
  function stage() public constant returns(uint256);

  /// @notice if it supports it, return the contribution by ID
  /// @return returns the contribution tx sender, value and time sent
  function contributions(uint256 _contributionID) public constant returns(address _sender, uint256 _value, uint256 _time) {}

  // Campaign events
  event ContributionMade (address _contributor);
  event RefundPayoutClaimed(address _payoutDestination, uint256 _payoutAmount);
  event BeneficiaryPayoutClaimed (address _payoutDestination);
}
