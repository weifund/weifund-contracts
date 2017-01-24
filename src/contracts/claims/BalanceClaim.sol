/*
This file is part of WeiFund.
*/

/*
The balance claim is used for dispersing balances of refunds for standard
camaign contracts. Instead of the contract sending a balance directly to the
contributor, it will send the balance to a balancelciam contract.
*/

pragma solidity ^0.4.4;

import "claims/Claim.sol";
import "utils/Owned.sol";


/// @title The balance claim interface contract, used for defining balance claims.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract BalanceClaimInterface {
  /// @dev used to claim balance of the balance claim
  function claimBalance() public {}
}


/// @title The balance claim, used for sending balances owed to a claim contract.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract BalanceClaim is Owned, Claim, BalanceClaimInterface {
  /// @notice receive funds
  function () payable public {}

  /// @dev the claim balance method, claim the balance then suicide the contract
  function claimBalance() onlyowner public {
    // self destruct and send all funds to the balance claim owner
    selfdestruct(owner);
  }

  /// @notice The BalanceClaim constructor method
  /// @param _owner the address of the balance claim owner
  function BalanceClaim(address _owner) {
    // specify the balance claim owner
    owner = _owner;
  }

  // the claim method ABI metadata for user interfaces, written in standard
  // solidity ABI method format
  string constant public claimMethodABI = "claimBalance()";
}
