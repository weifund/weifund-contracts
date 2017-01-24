/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "registries/CurationRegistry.sol";

contract User {
  function () payable {}

  function approve (address _service, address _reg){
    CurationRegistry(_reg).approve(_service);
  }
}

contract CurationRegistryTest is Test {
  CurationRegistry reg;
  User a;
  User b;
  User c;
  address service;

  function setup() {
    a = new User();
    b = new User();
    c = new User();
    if(!a.send(50000)){ throw; }
    if(!b.send(50000)){ throw; }
    if(!c.send(50000)){ throw; }
    service = address(new User());
  }

  function beforeEach() {
    reg = new CurationRegistry();
  }

  function test_curatorIdOf() {
    a.approve(address(b), address(reg));
    b.approve(address(c), address(reg));
    assertEq(reg.curatorIDOf(address(a)), uint(0), "Should be 0");
    assertEq(reg.curatorIDOf(address(b)), uint(1), "Should be 1");
  }

  function test_curatorAddressOf() {
    a.approve(address(b), address(reg));
    b.approve(address(c), address(reg));
    assertEq(reg.curatorAddressOf(0), address(a));
    assertEq(reg.curatorAddressOf(1), address(b));
  }

  function test_approveAndCheckServiceApprovedBy() {
    assertFalse(reg.serviceApprovedBy(address(a), address(b)));
    a.approve(address(b), address(reg));
    assertTrue(reg.serviceApprovedBy(address(a), address(b)));
  }

  function test_approveAndCheckServiceAddressOf (){
    a.approve(address(b),address(reg));
    assertEq(reg.serviceAddressOf(address(a), 0), address(b));
  }
}
