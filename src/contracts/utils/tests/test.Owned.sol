pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "utils/Owned.sol";

contract OwnedExample is Owned {
  uint public someStore = 0;

  function OwnedExample(address _owner) {
    owner = _owner;
  }

  function someMethod(uint _val) onlyowner() {
    someStore = _val;
  }
}

contract OwnedUser {
  function () payable {}

  function attemptSomeMethod(address _example, uint _val) {
    OwnedExample(_example).someMethod(_val);
  }
}

contract TestOwned is Test {
  OwnedExample target;
  OwnedUser user;
  OwnedUser user2;

  function setup() {
    user = new OwnedUser();
    user2 = new OwnedUser();

    if (!user2.send(5000)) {
      throw;
    }

    target = new OwnedExample(address(this));
  }

  // test normal owner access restriciton
  function test_0_validOwner_construction() {
    assertEq(target.owner(), address(this));
  }

  // test normal owner access restriciton
  function test_1_validOwner_accessRestriction() {
    assertEq(target.someStore(), uint(0));
    target.someMethod(3);
    assertEq(target.someStore(), uint(3));
  }

  // test non owner attempt access restriction
  function testThrow_2_invalidOwner_accessRestrictionThrow() {
    user2.attemptSomeMethod(address(target), uint(6));
  }

  // test access restriciton with low gas
  function testThrow_3_invalidOwner_accessRestrictionThrow() {
    user2.attemptSomeMethod(address(target), uint(8));
  }
}
