/*
This file is part of WeiFund.
*/

/*
The private service registry is used in WeiFund factory contracts to register
generated service contracts, such as our WeiFund standard campaign and enhanced
standard campaign contracts. It is usually only inherited by other contracts.
*/

pragma solidity ^0.4.4;


/// @title Private Service Registry - used to register generated service contracts.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract PrivateServiceRegistryInterface {
  /// @notice register the service '_service' with the private service registry
  /// @param _service the service contract to be registered
  /// @return the service ID 'serviceId'
  function register(address _service) internal returns (uint256 serviceId) {}

  /// @notice is the service in question '_service' a registered service with this registry
  /// @param _service the service contract address
  /// @return either yes (true) the service is registered or no (false) the service is not
  function isService(address _service) public constant returns (bool) {}

  /// @notice helps to get service address
  /// @param _serviceId the service ID
  /// @return returns the service address of service ID
  function services(uint256 _serviceId) public constant returns (address _service) {}

  /// @notice returns the id of a service address, if any
  /// @param _service the service contract address
  /// @return the service id of a service
  function ids(address _service) public constant returns (uint256 serviceId) {}

  event ServiceRegistered(address _sender, address _service);
}

contract PrivateServiceRegistry is PrivateServiceRegistryInterface {

  modifier isRegisteredService(address _service) {
    // does the service exist in the registry, is the service address not empty
    if (services.length > 0) {
      if (services[ids[_service]] == _service && _service != address(0)) {
        _;
      }
    }
  }

  modifier isNotRegisteredService(address _service) {
    // if the service '_service' is not a registered service
    if (!isService(_service)) {
      _;
    }
  }

  function register(address _service)
    internal
    isNotRegisteredService(_service)
    returns (uint serviceId) {
    // create service ID by increasing services length
    serviceId = services.length++;

    // set the new service ID to the '_service' address
    services[serviceId] = _service;

    // set the ids store to link to the 'serviceId' created
    ids[_service] = serviceId;

    // fire the 'ServiceRegistered' event
    ServiceRegistered(msg.sender, _service);
  }

  function isService(address _service)
    public
    constant
    isRegisteredService(_service)
    returns (bool) {
    return true;
  }

  address[] public services;
  mapping(address => uint256) public ids;
}
