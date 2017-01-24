/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "claims/BalanceClaim.sol";


contract ClaimUser {
  function newBalanceClaim() returns (address) {
    return address(new BalanceClaim(address(this)));
  }

  function claimBalance(address _balanceClaim) {
    BalanceClaim(_balanceClaim).claimBalance();
  }

  function claimBalance(address _balanceClaim, uint _value) {
    if (!BalanceClaim(_balanceClaim).call.value(_value)(bytes4(sha3("claimBalance()")))) {
      throw;
    }
  }
}

contract TestBalanceClaim is Test {
  BalanceClaim target;
  ClaimUser user;
  ClaimUser user2;
  ClaimUser user3;

  function setup() {
    user = new ClaimUser();
    user2 = new ClaimUser();
    user3 = new ClaimUser();
  }

  /// @dev reset the claim target, send ether
  function beforeEach() {
    target = new BalanceClaim(address(user));
    if (!target.send(5000)) {
      throw;
    }
  }

  /// @dev test that the claim functions properly under normal situations
  function test_validClaim() {
    assertEq(user.balance, uint(0));
    assertEq(target.balance, uint(5000));
    user.claimBalance(target);
    assertEq(user.balance, uint(5000));
    assertEq(target.balance, uint(0));
  }

  /// @dev make sure noone except the owner can claim the balance
  function test_invalidClaim_accessRestriction_throw () {
    user2.claimBalance(target);
  }

  /// @dev make sure noone except the owner can claim the balance
  function test_invalidClaim_withValue_throw () {
    user2.claimBalance(target, 3500);
  }
}
