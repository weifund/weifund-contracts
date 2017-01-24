/*
This file is part of WeiFund.
*/

/*
This is the standard claim contract interface. This used accross all claim
contracts. Claim contracts are used for the pickup of digital assets, such as tokens.
Note, a campaign enhancer could be a claim as well. This is our general
claim interface.
*/

pragma solidity ^0.4.4;


/// @title Claim contract interface.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Claim {
  /// @return returns the claim ABI solidity method for this claim
  function claimMethodABI() constant public returns (string) {}

  // the claim success event, used for whent he claim has successfully be used
  event ClaimSuccess(address _sender);
}
