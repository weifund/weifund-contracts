/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "factories/Model1EnhancerFactory.sol";
import "enhancers/Model1Enhancer.sol";

contract Model1EnhancerFactoryTest is Test {
  Model1EnhancerFactory target;
  uint tokenCap = 500000;
  uint tokenPrice = 0.23 ether;
  uint freezePeriod = 10000;
  address token = address(0);
  address[] initFunders;
  uint[] initBalances;
  address verifier = address(this);

  /// @dev deploy the factory, use it in the tests
  function setup() {
    target = new Model1EnhancerFactory();
  }

  /// @dev test valid deployment, make sure all registry information is valid
  function test_validDeployment() {
    Model1Enhancer enhancer = Model1Enhancer(address(target.createModel1Enhancer(
      tokenCap,
      tokenPrice,
      freezePeriod,
      token,
      initFunders,
      initBalances,
      verifier)));

    assertTrue(target.isService(address(enhancer)), "enhancer is service");
    assertEq(enhancer.price(), tokenPrice, "price is right");
    assertEq(enhancer.tokenCap(), tokenCap, "cap is right");
    assertEq(enhancer.freezePeriod(), freezePeriod, "f period is right");
    assertEq(enhancer.token(), token, "token is right");
    assertEq(enhancer.owner(), address(this), "token is right");
    assertEq(enhancer.verifier(), address(this), "verifier is right");
  }
}
