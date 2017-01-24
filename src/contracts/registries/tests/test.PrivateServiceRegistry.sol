/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "registries/PrivateServiceRegistry.sol";

contract PrivServiceReg is PrivateServiceRegistry {
  function () payable {}

  function registerUnPriv(address _service) isNotRegisteredService(_service) returns (uint) {
    return super.register(_service);
  }
}

contract service {}

contract PrivateServiceRegistryTest is Test {
  PrivServiceReg reg;

  function beforeEach() {
    reg = new PrivServiceReg();
    if(!reg.send(50000)){ throw; }
  }

  function test_registerServices() {
    service a = new service();
    service b = new service();
    assertEq(reg.registerUnPriv(address(a)), 0);
    assertEq(reg.registerUnPriv(address(b)), 1);
    // Test function services
    assertEq(reg.services(0), address(a));
    assertEq(reg.services(1), address(b));
    //Test Function Ids
    assertEq(reg.ids(address(a)), 0);
    assertEq(reg.ids(address(b)), 1);
  }

  function test_registerDouble(){
    service a = new service();
    assertEq(reg.registerUnPriv(address(a)), 0);
    assertTrue(reg.isService(address(a)));
    assertEq(reg.registerUnPriv(address(a)), 0);
  }
}
