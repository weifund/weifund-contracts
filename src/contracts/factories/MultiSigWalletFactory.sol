/*
This file is part of WeiFund.
*/

/*
A factory contract used for the generation and registration of MultiSig wallet
contracts.
*/

pragma solidity ^0.4.4;

import "registries/PrivateServiceRegistry.sol";
import "wallets/MultiSigWallet.sol";


/// @title MultiSig Wallet Factory - used to generate and register MultiSig wallets
/// @author Nick Dodson <nick.dodson@consensys.net>
contract MultiSigWalletFactory is PrivateServiceRegistry {
  function createMultiSigWallet(address[] _owners, uint256 _required)
  public
  returns (address walletAddress) {
    // create a new multi sig wallet
    walletAddress = address(new MultiSigWallet(
      _owners,
      _required));

    // register that multisig wallet address as service
    register(walletAddress);
  }
}
