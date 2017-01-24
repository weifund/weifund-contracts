/*
This file is part of WeiFund.
*/

/*
A factory to generate the Model1Enhancers contracts.
*/

pragma solidity ^0.4.4;

import "registries/PrivateServiceRegistry.sol";
import "enhancers/Model1Enhancer.sol";


/// @title Model 1 Enhancer Factory -- for generating and registering model 1 enhancers
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Model1EnhancerFactory is PrivateServiceRegistry {
  function createModel1Enhancer(
    uint256 _tokenCap,
    uint256 _tokenPrice,
    uint256 _freezePeriod,
    address _token,
    address[] _initFunders,
    uint256[] _initBalances,
    address _verifier)
  public
  returns (address enhancerAddress) {
    // create a new multi sig wallet
    enhancerAddress = address(new Model1Enhancer(
      _tokenCap,
      _tokenPrice,
      _freezePeriod,
      _token,
      _initFunders,
      _initBalances,
      msg.sender,
      _verifier));

    // register that multisig wallet address as service
    register(enhancerAddress);
  }
}
