/*
This file is part of WeiFund.
*/

/*
Used for contracts that have an issuer.
*/

pragma solidity ^0.4.4;


/// @title Issued - interface used for build issued asset contracts
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Issued {
  /// @notice will set the asset issuer address
  /// @param _issuer The address of the issuer
  function setIssuer(address _issuer) public {}
}
