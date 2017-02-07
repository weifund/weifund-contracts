/*
This file is part of WeiFund.
*/

/*
A generic token issuance and dispersal enhancer for a generic WeiFund standard
campaign. Works well with the WeiFund IssuedToken contract.
*/

pragma solidity ^0.4.4;

/*
Interfaces
*/
import "claims/Claim.sol";
import "tokens/Token.sol";

/*
Implemented
*/
import "enhancers/CampaignEnhancer.sol";
import "verifiers/Verifier.sol";
import "utils/Owned.sol";

/// @title Model 1 Enhancer, used to issue tokens against a linear price and solid cap
/// @author Nick Dodson <nick.dodson@consensys.net>
contract Model1Enhancer is Owned, Claim, CampaignEnhancer {
  modifier validTokenClaim() {
    // the current block number must be greater than the startBlock + freezePeriod
    // the user cannot have previously claimed any tokens, and the sender
    // must have a token balance to be issued, otherwise throw
    if (block.number > (startBlock + freezePeriod)
      && claimed[msg.sender] == false
      && balances[msg.sender] > 0) {
      // carry on with state changing operations
      _;
    } else {
      // throw, invalid token claim attempt
      throw;
    }
  }

  modifier validContribution(address _sender, uint256 _value) {
    // calculate token amount to be issued
    uint256 tokenAmount = calcTokenAmount(_value);
    uint256 valueCalc = tokenAmount * price;

    // check if user contributed enough for any tokens, then check if user
    // contributed too much, above the funding cap, if not, the carry on
    if (tokenAmount > 0
      && valueCalc == _value
      && (address(verifier) == address(0) || verifier.approved(_sender))
      && (tokensIssued + tokenAmount) <= tokenCap) {
      // carry on with state changing operations
      _;
    } else {
      // throw error, invalid contribution
      throw;
    }
  }

  /// @notice calculate total tokens to issue for this wei uint256 value
  /// @param _value The wei value
  /// @return The tokens to be issued
  function calcTokenAmount(uint256 _value) public constant returns (uint256) {
    // the token price = the wei value / the price wei value
    return _value / price;
  }

  function notate(address _sender,
    uint256 _value,
    uint256 _blockNumber,
    uint256[] _amounts)
    public
    validContribution(_sender, _value)
    onlycampaign()
    returns (bool earlySuccess) {
    // calculate token amount to be issued to user
    uint tokenAmount = calcTokenAmount(_value);

    // increase the senders token amount by token amount
    balances[_sender] += tokenAmount;

    // increase total tokens issued by token amount
    tokensIssued += tokenAmount;

    // check if token cap is reached, if so, set early success
    if (tokensIssued >= tokenCap) {
      earlySuccess = true;
    }
  }

  /// @notice claim tokens owed to msg.sender, if any, else throw
  /// @dev will throw if claim is invalid, see: modifier validTokenClaim
  function claim()
    public
    atStage(Stages.CrowdfundSuccess)
    validTokenClaim() {
    // set the sender claimed prop to be true before transfer
    // to prevent any funny biz.
    claimed[msg.sender] = true;

    // attempt to transfer (i.e issue) standard tokens to the sender
    // throw if invalid
    if (!token.transfer(msg.sender, balances[msg.sender])) {
      throw;
    } else {
      // fire claim event success for sender
      ClaimSuccess(msg.sender);
    }
  }

  /// @notice get balance of a specific user, follow ERC20 standard balanceOf
  /// @dev balance of a sepcific sender
  function balanceOf(address _sender) public constant returns (uint256) {
    return balances[_sender];
  }

  /// @notice allow owner to change price in the enhancer
  /// @dev change the price of the enhancer
  function changePrice(uint256 _price) public onlyowner() {
    price = _price;
  }

  function Model1Enhancer(
    uint256 _tokenCap,
    uint256 _tokenPrice,
    uint256 _freezePeriod,
    address _token,
    address[] _initFunders,
    uint256[] _initBalances,
    address _owner,
    address _verifier) {
    // set token cap in token base unit
    tokenCap = _tokenCap;

    // set token price in wei
    price = _tokenPrice;

    // set token freeze period in block numbers
    freezePeriod = _freezePeriod;

    // the block when the enhancer was created
    startBlock = block.number;

    // the token to be dispersed
    token = Token(_token);

    verifier = Verifier(_verifier);

    // set owner
    owner = _owner;

    // the initial funder balances, if any, ready for claim
    for (uint256 funder = 0; funder < uint256(_initFunders.length); funder++) {
      // set funder balance
      balances[_initFunders[funder]] += _initBalances[funder];

      // increase tokens to be issued
      tokensIssued += _initBalances[funder];
    }
  }

  // the token to be dispersed by claim
  Token public token;

  // the contribution verifier, if any
  Verifier public verifier;

  // the block when this contract was created
  uint256 public startBlock;

  // the total amount of tokens issued by this contract
  uint256 public tokensIssued;

  // has the sender claimed their tokens or not
  mapping(address => bool) public claimed;

  // the sender token balance to be issued
  mapping(address => uint256) public balances;

  // the total amount of tokens
  uint256 public tokenCap;

  // the price of a single token in wei (using ether conversion)
  uint256 public price;

  // the transfer freeze period in blocks
  uint256 public freezePeriod;

  // the claim method ABI, specified for this contract to claim tokens owed
  string public constant claimMethodABI = "claim()";
}
