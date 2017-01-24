pragma solidity ^0.4.4;

import "campaigns/CampaignEnhancer.sol";
import "campaigns/StandardCampaign.sol";

// always success, see what happens
contract AttackEnhancer0_alwaysSuccess is CampaignEnhancer {
  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    return true;
  }
}

// always throw, causing contribution to never work
contract AttackEnhancer1_alwaysThrow is CampaignEnhancer {
  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    throw;
  }
}

// attempt to send sender value
contract AttackEnhancer2_sendSenderValue is CampaignEnhancer {
  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    if (_sender.send(_value)) {
      throw;
    }
  }
}

// attempt to send hacker value from campaign contract
contract AttackEnhancer3_sendHackerHalf is CampaignEnhancer {
  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    if (hacker.send(_value / 2)) {
      throw;
    }
  }

  address public hacker;
}

// call contribute again with no value
contract AttackEnhancer4_callContributeNoValue is CampaignEnhancer {
  uint[] testValue;

  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    if (msg.sender.call.value(0)(bytes4(sha3("contributeMsgValue(uint256[]):(uint256)")), testValue)) {
      throw;
    }
  }

  address public hacker;
}

// call contribute with value while contribution is in process
// gas is required for this campaign
contract AttackEnhancer5_callContributeWithValue is CampaignEnhancer {
  uint[] testValue;

  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    if (!msg.sender.call.value(50000)(bytes4(sha3("contributeMsgValue(uint256[]):(uint256)")), testValue)) {
      throw;
    }
  }

  address public hacker;
}

// an attack enhancer to call refund while contribution in process
contract AttackEnhancer6_callRefund is CampaignEnhancer {
  uint[] testValue;

  /// @dev always throw
  function notate(address _sender, uint256 _value, uint256 _time, uint256[] _amounts) public returns (bool earlySuccess) {
    uint poentialContributionID = StandardCampaign(msg.sender).totalContributions();

    if (msg.sender.call.value(0)(bytes4(sha3("claimRefundOwed(uint256):(address)")), poentialContributionID)) {
      throw;
    }
  }
}
