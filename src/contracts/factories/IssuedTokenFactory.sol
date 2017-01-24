/*
This file is part of WeiFund.
*/

/*
A factory to generate the IssuedToken contracts.
*/

pragma solidity ^0.4.4;

import "registries/PrivateServiceRegistry.sol";
import "tokens/IssuedToken.sol";


/// @title Issued Token Factory - used to generate and register IssuedToken contracts
/// @author Nick Dodson <nick.dodson@consensys.net>
contract IssuedTokenFactory is PrivateServiceRegistry {
  function createIssuedToken(
    address[] _addrs,
    uint256[] _amounts,
    uint256 _freezePeriod,
    uint256 _lastIssuance,
    string _name,
    uint8 _decimals,
    string _symbol)
  public
  returns (address tokenAddress) {
    // create a new multi sig wallet
    tokenAddress = address(new IssuedToken(
      _addrs,
      _amounts,
      _freezePeriod,
      _lastIssuance,
      msg.sender,
      _name,
      _decimals,
      _symbol));

    // register that multisig wallet address as service
    register(tokenAddress);
  }
}
