/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "factories/MultiSigWalletFactory.sol";
import "wallets/MultiSigWallet.sol";

contract TestMultiSigWalletFactory is Test {
  MultiSigWalletFactory target;
  address[] owners;

  /// @dev deploy the factory, use it in the tests
  function setup() {
    target = new MultiSigWalletFactory();
  }

  /// @dev test valid deployment, make sure all registry information is valid
  function test_validDeployment() {
    owners.push(address(this));
    owners.push(address(target));

    MultiSigWallet wallet = MultiSigWallet(address(target.createMultiSigWallet(owners, 1)));

    assertEq(wallet.owners(0), address(this), "owner 1 right");
    assertEq(wallet.owners(1), address(target), "owner 2 right");
    assertTrue(target.isService(address(wallet)), "wallet is service");
  }
}
