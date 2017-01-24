/*
This file is part of WeiFund.
*/

/*
An empty campaign enhancer, used to fulfill an enhancer of a WeiFund enhanced
standard campaign.
*/

pragma solidity ^0.4.4;

import "enhancers/Enhancer.sol";


/// @title Empty Enhancer - used to test enhanced standard campaign contracts
/// @author Nick Dodson <nick.dodson@consensys.net>
contract EmptyEnhancer is Enhancer {
  /// @dev notate contribution data, and trigger early success if need be
  function notate(address _sender, uint256 _value, uint256 _blockNumber, uint256[] _amounts)
  public
  returns (bool earlySuccess) {
    return false;
  }
}
