/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "factories/IssuedTokenFactory.sol";
import "tokens/IssuedToken.sol";

contract TestIssuedTokenFactory is Test {
  IssuedTokenFactory target;
  address[] addrs;
  uint256[] amounts;
  uint256 freezePeriod = 10150;
  uint256 lastIssuance = 1000;

  /// @dev deploy the factory, use it in the tests
  function setup() {
    target = new IssuedTokenFactory();
  }

  /// @dev test valid deployment, make sure all registry information is valid
  function test_validDeployment() {
    IssuedToken token = IssuedToken(address(target.createIssuedToken(
      addrs,
      amounts,
      freezePeriod,
      lastIssuance,
      "Nick Tokens",
      10,
      "NT"
      )));

    assertTrue(target.isService(address(token)), "token is service");
  }
}
