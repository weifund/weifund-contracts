/*
This file is part of WeiFund.
*/

/*
A campaign verifier, this is usally for compliance oracles and registries.
*/

pragma solidity ^0.4.4;

import "utils/Owned.sol";
import "verifiers/Verifier.sol";


/// @title The owned verifier - used for compliance purposes on certain campaigns
/// @author Nick Dodson <nick.dodson@consensys.net>
contract OwnedVerifier is Owned {
  function setApproval(address _sender, bool _status) onlyowner {
    approved[_sender] = _status;
  }

  function transfer_ownership(address _owner) onlyowner {
    owner = _owner;
  }

  function OwnedVerifier(address _owner) {
    owner = _owner;
  }

  mapping(address => bool) public approved;
}
