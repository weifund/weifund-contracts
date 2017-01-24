/*
This file is part of WeiFund.

WeiFund is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

pragma solidity ^0.4.4;

import "wafr/Test.sol";
import "wallets/MultiSigWallet.sol";

contract MultiSigUser {
  function () payable {}

  function addOwner (address _owner, address _wallet) {
    MultiSigWallet(_wallet).addOwner(_owner);
  }

  function submitTx (address _dest, uint _val, bytes _data, uint _nonce, address _wallet) returns (bytes32 txhash) {
    txhash = MultiSigWallet(_wallet).submitTransaction(_dest, _val, _data, _nonce);
  }

  function confirmTx (bytes32 _txhash, address _wallet) {
    MultiSigWallet(_wallet).confirmTransaction(_txhash);
  }
}

contract MultiSigProxy is MultiSigWallet {
  function () payable {}

  function MultiSigProxy (address [] _owners, uint _required) MultiSigWallet(_owners, _required){}

  function removeOwnerProxy (address _owner) {
    this.removeOwner (_owner);
  }

  function addOwnerProxy (address _owner) {
    this.addOwner (_owner);
  }

  function changeRequirementProxy (uint _requirement) {
    this.changeRequirement(_requirement);
  }
}

contract MultiSigWalletTest is Test {
    MultiSigProxy wallet;
    address [] list_of_users;

    function setup() {
      MultiSigUser user;
      for (int i = 0 ; i < 5 ; i++){
        user = new MultiSigUser();
        if(!user.send(10000)){throw;}
        list_of_users.push(address (user));
      }
    }
    function beforeEach() {
      wallet = new MultiSigProxy(list_of_users, 3);
      if(wallet.send(100000000000)){}
    }

    function test_setup_is_correct(){
      assertEq(wallet.required(),  uint256(3), "Only 3 required as per setup");
      for(uint i = 0 ; i < 5 ; i ++){
        assertTrue(wallet.isOwner(list_of_users[i]), "Should all be true");
      }
    }

    function test_addingOwnerAsWallet() {
      assertFalse(wallet.isOwner(0), "User with address 0 not added yet");
      wallet.addOwnerProxy(0);
      assertTrue(wallet.isOwner(0), "User with Address 0 should be added");
    }

    function test_addingOwnerNotAsWalletShouldThrow() {
      MultiSigUser u = new MultiSigUser();
      u.addOwner(address(u), address(wallet));
    }

    function test_removingOwnerAsWallet() {
      assertTrue(wallet.isOwner(list_of_users[0]), "User  should be owner");
      wallet.removeOwnerProxy(list_of_users[0]);
      assertFalse(wallet.isOwner(list_of_users[0]), "User should be removed");
    }

    function test_validUpdateRequirment() {
      assertEq(wallet.required(), uint256(3));
      wallet.changeRequirementProxy(2);
      assertEq(wallet.required(), uint256(2));
      wallet.changeRequirementProxy(1);
      assertEq(wallet.required(), uint256(1));
    }
    function test_invalidUpdateRequirmentThrow() {
      assertEq(wallet.required(), uint256(3));
      wallet.changeRequirementProxy(6);
    }
    /*
    function test_txGoesThrough() {
        User u = new User();
        assertEq(u.balance, 0, "init balance is 0");
        uint nonce = wallet.getNonce(address(u), 20, "");
        assertEq(nonce, 0, "0/3 confirmed");

        bytes32 txhash = User(list_of_users[0]).submitTx(address(u), 20, "", nonce, address(wallet));
        assertEq(wallet.getTransactionCount(true, false), 1);
        assertEq(wallet.getTransactionCount(true, true), 1);
        assertEq(wallet.getTransactionCount(false, true), 0);

        assertFalse(wallet.isConfirmed(txhash));
        assertEq(wallet.getConfirmationCount(txhash), 1);
        assertEq(u.balance, 0, "1/3 confirmed");
        assertEq(wallet.getTransactionCount(true, false), 1);
        assertEq(wallet.getTransactionCount(true, true), 1);
        assertEq(wallet.getTransactionCount(false, true), 0);


        User(list_of_users[1]).confirmTx(txhash, address(wallet));
        assertFalse(wallet.isConfirmed(txhash));
        assertEq(wallet.getConfirmationCount(txhash), 2);
        assertEq(wallet.getTransactionCount(true, false), 1);
        assertEq(wallet.getTransactionCount(true, true), 1);
        assertEq(wallet.getTransactionCount(false, true), 0);

        assertEq(u.balance, 0, "2/3 confirmed");

        User(list_of_users[2]).confirmTx(txhash, address(wallet));
        assertTrue(wallet.isConfirmed(txhash));
        assertEq(wallet.getConfirmationCount(txhash), 3);

        wallet.executeTransaction(txhash);

        assertEq(wallet.getTransactionCount(true, false), 0);
        assertEq(wallet.getTransactionCount(true, true), 1);
        assertEq(wallet.getTransactionCount(false, true), 1);
        assertEq(u.balance, 20, "3/3 confirmed");
    }
    */
}
