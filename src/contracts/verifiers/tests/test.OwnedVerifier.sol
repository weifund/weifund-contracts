pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "verifiers/OwnedVerifier.sol";


contract TestOwnedVerifier is Test {
  OwnedVerifier target;

  function setup() {
    target = new OwnedVerifier(address(this));
  }

  function test_0_verification() {
    assertEq(target.approved(address(this)), false);
    target.setApproval(address(this), true);
    assertEq(target.approved(address(this)), true);
  }

  function test_1_transferOwnership() {
    assertEq(target.owner(), address(this));
    target.transfer_ownership(address(0));
    assertEq(target.owner(), address(0));
  }
}
