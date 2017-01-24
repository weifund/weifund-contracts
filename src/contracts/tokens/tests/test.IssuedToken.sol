pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "tokens/IssuedToken.sol";
import "tokens/Token.sol";

contract SomeTokenUser {
  function transfer(address _target, address _to, uint256 _value) returns (bool success) {
    return Token(_target).transfer(_to, _value);
  }

  function transferFrom(address _target, address _from, address _to, uint256 _value) returns (bool success) {
    return Token(_target).transferFrom(_from, _to, _value);
  }
}

contract IssuedTokenTest_EmptyConstruction_onlyOnce is Test {
  address[] addrs;
  uint256[] vals;
  IssuedToken target;
  SomeTokenUser issuer;
  SomeTokenUser user;
  SomeTokenUser user2;

  function setup() {
    target = new IssuedToken(addrs, vals, 0, 0, address(this), "Nick Tokens", 10, "NT");
    issuer = new SomeTokenUser();
    user = new SomeTokenUser();
    user2 = new SomeTokenUser();
  }

  function test_tokenDeployment() {
    assertEq(target.owner(), address(this), "the owner is the test contract");
    assertEq(target.lastIssuance(), 0);
    assertEq(target.freezePeriod(), 0);
  }

  function test_0_setIssuer() {
    target.setIssuer(address(issuer));
    assertEq(target.issuer(), address(issuer), "issuer address should be right");
  }

  function test_1_tokenIssuanceTransfer() {
    assertEq(issuer.transfer(address(target), address(0), 50000), true);
    assertEq(target.balanceOf(address(0)), 50000);
    assertEq(issuer.transfer(address(target), address(0), 40392), true);
    assertEq(target.balanceOf(address(0)), 50000 + 40392);
  }

  function test_1_tokenUserTransfer() {
    assertEq(issuer.transfer(address(target), address(user), 42982023), true);
    assertEq(target.balanceOf(address(user)), 42982023);
    assertEq(user.transfer(address(target), address(user2), 50000), true);
    assertEq(target.balanceOf(address(user2)), 50000);
  }

  function test_1_invalidSetIssuer_twice_shouldThrow() {
    target.setIssuer(address(0));
  }
}
