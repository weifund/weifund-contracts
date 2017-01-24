/*
This file is part of WeiFund.
*/

/*
The curation registry is used for curating WeiFund campaigns. Anyone can technically use
this registry, to curate any number of campaign contract ID's. The WeiFund UI
will only be responsive to curation done by WeiFund, at the begining.
*/

pragma solidity ^0.4.4;


/// @title Curation Registry Interface - used to build curation registries.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract CurationRegistryInterface {
  /// @notice approve a specific campaign contract
  /// @param _service The contract address of the service approved
  function approve(address _service) public {}

  /// @notice input curator ID and get the curator sender address
  /// @param _curatorID the ID of the curator
  /// @return the message sender (msg.sender) address of the curator
  function curatorAddressOf(uint256 _curatorID) public constant returns (address) {}

  /// @notice input the curator sender address and get the curator ID
  /// @param _curator the curator sender address
  /// @return the curator ID
  function curatorIDOf(address _curator) public constant returns (uint256) {}

  /// @notice input the curator sender address and the service address get bool "is approved" value
  /// @param _curator the curator sender address
  /// @param _service the service address
  /// @return a bool "is service approved by curator" value
  function serviceApprovedBy(address _curator, address _service) public constant returns (bool) {}

  /// @notice input the curator and approval ID get the service address
  /// @param _curator the curator sender address
  /// @param _approvalID the approval ID
  /// @return the address of the service
  function serviceAddressOf(address _curator, uint _approvalID) public constant returns (address) {}

  event CampaignApproved(address _curator, address _service);
}


/// @title Curation Registry, used to curate WeiFund campaigns
/// @author Nick Dodson <nick.dodson@consensys.net>
contract CurationRegistry is CurationRegistryInterface {
  function approve(address _service) public {
    // check to see if the curator is added
    // if not add the curator
    if (uint256(curators.length) == 0 || curators[ids[msg.sender]] != msg.sender) {
      uint256 curatorID = curators.length++;
      curators[curatorID] = msg.sender;
      ids[msg.sender] = curatorID;
    }

    // if the service is not already approved, approve the campaign address
    // keep array storage clean
    if (approvals[msg.sender][_service] == false) {
      approved[msg.sender].push(_service);
      approvals[msg.sender][_service] = true;
    }

    // fire the campaign approved event
    CampaignApproved(msg.sender, _service);
  }

  function curatorAddressOf(uint256 _curatorID) public constant returns (address) {
    return curators[_curatorID];
  }

  function curatorIDOf(address _curator) public constant returns (uint256) {
    return ids[_curator];
  }

  function serviceApprovedBy(address _curator, address _service) public constant returns (bool) {
    return approvals[_curator][_service];
  }

  function serviceAddressOf(address _curator, uint256 _approvalID) public constant returns (address) {
    return approved[_curator][_approvalID];
  }

  address[] curators;
  mapping(address => uint256) ids;
  mapping(address => address[]) approved;
  mapping(address => mapping(address => bool)) approvals;
}
