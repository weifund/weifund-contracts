/*
This file is part of WeiFund.
*/

/*
A generic issued EC20 standard token, that can be issued by an issuer which the owner
of the contract sets. The issuer can only be set once if the onlyOnce option is true.
There is a freezePeriod option on transfers, if need be. There is also an date of
last issuance setting, if set, no more tokens can be issued past that time.

The token uses the a standard token API as much as possible, and overrides the transfer
and transferFrom methods. This way, we dont need special API's to issue this token.
We can retain the original StandardToken api, but add additional features.

Upon construction, initial token holders can be specified with their values.
Two arrays must be used. One with the token holer addresses, the other with the token
holder balances. They must be aligned by array index.
*/

pragma solidity ^0.4.4;

import "utils/Owned.sol";
import "tokens/StandardToken.sol";
import "tokens/Issued.sol";


/// @title Issued token contract allows new tokens to be issued by an issuer.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract IssuedToken is Owned, Issued, StandardToken {
  function transfer(address _to, uint256 _value) public returns (bool) {
    // if the issuer is attempting transfer
    // then mint new coins to address of transfer
    // by using transfer, we dont need to switch StandardToken API method
    if (msg.sender == issuer && (lastIssuance == 0 || block.number < lastIssuance)) {
      // increase the balance of user by transfer amount
      balances[_to] += _value;

      // increase total supply by balance
      totalSupply += _value;

      // return required true value for transfer
      return true;
    } else {
      if (freezePeriod == 0 || block.number > freezePeriod) {
        // continue with a normal transfer
        return super.transfer(_to, _value);
      }
    }
  }

  function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success) {
    // if we are passed the free period, then transferFrom
    if (freezePeriod == 0 || block.number > freezePeriod) {
      // return transferFrom
      return super.transferFrom(_from, _to, _value);
    }
  }

  function setIssuer(address _issuer) public onlyowner() {
    // set the issuer
    if (issuer == address(0)) {
      issuer = _issuer;
    } else {
      throw;
    }
  }

  function IssuedToken(
    address[] _addrs,
    uint256[] _amounts,
    uint256 _freezePeriod,
    uint256 _lastIssuance,
    address _owner,
    string _name,
    uint8 _decimals,
    string _symbol) {
    // issue the initial tokens, if any
    for (uint256 i = 0; i < _addrs.length; i ++) {
      // increase balance of that address
      balances[_addrs[i]] += _amounts[i];

      // increase token supply of that address
      totalSupply += _amounts[i];
    }

    // set the transfer freeze period, if any
    freezePeriod = _freezePeriod;

    // set the token owner, who can set the issuer
    owner = _owner;

    // set the blocknumber of last issuance, if any
    lastIssuance = _lastIssuance;

    // set token name
    name = _name;

    // set decimals
    decimals = _decimals;

    // set sumbol
    symbol = _symbol;
  }

  // the transfer freeze period
  uint256 public freezePeriod;

  // the block number of last issuance (set to zero, if none)
  uint256 public lastIssuance;

  // the token issuer address, if any
  address public issuer;

  // token name
  string public name;

  // token decimals
  uint8 public decimals;

  // symbol
  string public symbol;

  // verison
  string public version = "WFIT1.0";
}
