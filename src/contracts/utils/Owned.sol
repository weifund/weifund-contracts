/*
This file is part of WeiFund.
*/

/*
A common Owned contract that contains properties for contract ownership.
*/

pragma solidity ^0.4.4;


/// @title A single owned campaign contract for instantiating ownership properties.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Owned {
  // only the owner can use this method
  modifier onlyowner() {
    if (msg.sender != owner) {
      throw;
    }

    _;
  }

  // the owner property
  address public owner;
}
