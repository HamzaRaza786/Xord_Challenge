// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "./AddressSet.sol";
import "hardhat/console.sol";
interface IdentityRegistryInterface {
    // Identity View Functions /////////////////////////////////////////////////////////////////////////////////////////
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );

    // Identity Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;

    // Recovery Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;

    // Events //////////////////////////////////////////////////////////////////////////////////////////////////////////
    event IdentityCreated(
        address indexed initiator, uint indexed ein,
        address recoveryAddress, address associatedAddress, address[] providers, address[] resolvers, bool delegated
    );
    event AssociatedAddressAdded(
        address indexed initiator, uint indexed ein, address approvingAddress, address addedAddress
    );
    event AssociatedAddressRemoved(address indexed initiator, uint indexed ein, address removedAddress);
    event ProviderAdded(address indexed initiator, uint indexed ein, address provider, bool delegated);
    event ProviderRemoved(address indexed initiator, uint indexed ein, address provider, bool delegated);
    event ResolverAdded(address indexed initiator, uint indexed ein, address resolvers);
    event ResolverRemoved(address indexed initiator, uint indexed ein, address resolvers);
    event RecoveryAddressChangeTriggered(
        address indexed initiator, uint indexed ein, address oldRecoveryAddress, address newRecoveryAddress
    );
    event RecoveryTriggered(
        address indexed initiator, uint indexed ein, address[] oldAssociatedAddresses, address newAssociatedAddress
    );
    event IdentityDestroyed(address indexed initiator, uint indexed ein, address recoveryAddress, bool resolversReset);
}
contract Erc1484 is IdentityRegistryInterface{
    using AddressSet for AddressSet.Set;
    uint32 maxEin = 0;
    struct identity{
        address recoveryAddress;
        AddressSet.Set associatedAddresses;
        AddressSet.Set providers;
        AddressSet.Set resolvers;
    }
    mapping(uint=>identity) registry;
    mapping(address=>uint) einadd; 
     function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        return _isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s);
    }
    function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {
        return ecrecover(messageHash, v, r, s) == _address;
    }
    function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return _isSigned(_address, keccak256(abi.encodePacked(prefix, messageHash)), v, r, s);
    }
    function identityExists(uint ein) override public view returns (bool){
        return ein <= maxEin && ein > 0;
    }
    function hasIdentity(address _address) override public view returns (bool){
        return identityExists(einadd[_address]);
    }
    function getEIN(address _address) override public view returns (uint ein){
        return einadd[_address];
    }
    function isAssociatedAddressFor(uint ein, address _address) override public view returns (bool){
        return einadd[_address] == ein;
    }
    function isProviderFor(uint ein, address provider) override public view returns (bool){
        return registry[ein].providers.contains(provider);
    }
    function isResolverFor(uint ein, address resolver) override public view returns (bool){
        return registry[ein].resolvers.contains(resolver);
    }
    function getIdentity(uint ein) override public view
    returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    ){
        identity storage id = registry[ein];
        return (id.recoveryAddress,id.associatedAddresses.members,id.providers.members,id.resolvers.members);
    }
    function createIdentity(address recoveryAddress, address[] memory providers, address[] memory resolvers)
    override public returns (uint ein){
        //identity storage id;
        maxEin+=1;
        registry[maxEin].recoveryAddress = recoveryAddress;
        registry[maxEin].associatedAddresses.insert(msg.sender);
        einadd[msg.sender] = maxEin;
        for( uint32 i = 0; i < providers.length;i++){
            registry[maxEin].providers.insert(providers[i]);
        }        
        for( uint32 i = 0; i < resolvers.length;i++){
            registry[maxEin].resolvers.insert(resolvers[i]);
        }
       emit IdentityCreated(msg.sender, maxEin, recoveryAddress, msg.sender, providers, resolvers, false);
       return maxEin;
    }
    function createIdentityDelegated(
    address recoveryAddress, address associatedAddress, address[] memory providers, address[] memory resolvers,
    uint8 v, bytes32 r, bytes32 s, uint timestamp) override public returns (uint ein){
        require(
            isSigned(
                associatedAddress,
                keccak256("Hello How are you?"),
                v, r, s
            ),
            "Permission denied."
        );
            
            maxEin+=1;
            registry[maxEin].recoveryAddress = recoveryAddress;
            registry[maxEin].associatedAddresses.insert(associatedAddress);
            einadd[associatedAddress] = maxEin;
            for( uint32 i = 0; i < providers.length;i++){
                registry[maxEin].providers.insert(providers[i]);
            }        
            for( uint32 i = 0; i < resolvers.length;i++){
                registry[maxEin].resolvers.insert(resolvers[i]);
            }
            emit IdentityCreated(msg.sender, maxEin, recoveryAddress, associatedAddress, providers, resolvers, true);
            return maxEin;
    }
    function addAssociatedAddress(
    address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp) override public{
        if(msg.sender == approvingAddress){
            require(
            isSigned(
                addressToAdd,
                keccak256("Hello How are you?"
                    //abi.encodePacked(address(this),timestamp
                ),
                v, r, s
            ),
            "Permission denied."
        );
        registry[einadd[approvingAddress]].associatedAddresses.insert(addressToAdd);
        einadd[addressToAdd] = einadd[approvingAddress];
        emit AssociatedAddressAdded(msg.sender, einadd[approvingAddress],approvingAddress,addressToAdd);        
        }
        else if(msg.sender == addressToAdd){
            require(
            isSigned(
                approvingAddress,
                keccak256(
                    //abi.encodePacked(address(this),timestamp
                    "Hello How are you"
                ),
                v, r, s
            ),
            "Permission denied."
        );
            registry[einadd[approvingAddress]].associatedAddresses.insert(addressToAdd);
            einadd[addressToAdd] = einadd[approvingAddress];
            emit AssociatedAddressAdded(msg.sender, einadd[approvingAddress],approvingAddress,addressToAdd);        
        }
    }
    function addAssociatedAddressDelegated(
    address approvingAddress, address addressToAdd,
    uint8[2] memory v, bytes32[2] memory r, bytes32[2] memory s, uint[2] memory timestamp) override public{
            require(
            isSigned(
                addressToAdd,
                keccak256(
                    //abi.encodePacked(address(this),timestamp
                    "Hello How are you?"
                ),
                v[1], r[1], s[1]
            ),
            "Permission denied 1."
        );
        require(
            isSigned(
                approvingAddress,
                keccak256(
                    //abi.encodePacked(address(this),timestamp
                    "Hello How are you?"
                ),
                v[0], r[0], s[0]
            ),
            "Permission denied 2."
        );
        registry[einadd[approvingAddress]].associatedAddresses.insert(addressToAdd);
        einadd[addressToAdd] = einadd[approvingAddress];
        emit AssociatedAddressAdded(msg.sender, einadd[approvingAddress],approvingAddress,addressToAdd);        
    }
    function removeAssociatedAddress() override public{
        registry[einadd[msg.sender]].associatedAddresses.remove(msg.sender);
        uint ei = einadd[msg.sender];
        delete einadd[msg.sender];
        emit AssociatedAddressRemoved(msg.sender,ei, msg.sender);
    }
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp) override public{
        require(
            isSigned(
                addressToRemove,
                keccak256(
                    //abi.encodePacked(address(this),timestamp
                    "Hello How are you?"
                ),
                v, r, s
            ),
            "Permission denied."
        );
        registry[einadd[addressToRemove]].associatedAddresses.remove(addressToRemove);
        uint ei = einadd[msg.sender];
        delete einadd[msg.sender];
        emit AssociatedAddressRemoved(msg.sender,ei, msg.sender);
    }
    function addProviders(address[] memory providers) override public{
        for( uint32 i = 0; i < providers.length;i++){
            registry[einadd[msg.sender]].providers.insert(providers[i]);
            emit ProviderAdded(msg.sender, einadd[msg.sender], providers[i], false);       
        }
    }
    function addProvidersFor(uint ein, address[] memory providers) override public{
        require(registry[ein].providers.contains(msg.sender),"Msg.sender not present");
        for( uint32 i = 0; i < providers.length;i++){
            registry[ein].providers.insert(providers[i]);
            emit ProviderAdded(msg.sender, ein, providers[i], true);       
        }
    }
    function removeProviders(address[] memory providers) override public{
        for( uint32 i = 0; i < providers.length;i++){
            registry[einadd[msg.sender]].providers.remove(providers[i]);
            emit ProviderRemoved(msg.sender, einadd[msg.sender], providers[i], false);
        }    
    }
    function removeProvidersFor(uint ein, address[] memory providers) override public{
        require(registry[ein].providers.contains(msg.sender),"Msg.sender not present");
        for( uint32 i = 0; i < providers.length;i++){
            registry[ein].providers.remove(providers[i]);
            emit ProviderRemoved(msg.sender, ein, providers[i], true);
        }   
    }
    function addResolvers(address[] memory resolvers) override public{
        for( uint32 i = 0; i < resolvers.length;i++){
            registry[einadd[msg.sender]].providers.insert(resolvers[i]);
            emit ResolverAdded(msg.sender, einadd[msg.sender], resolvers[i]);       
        }
    }
    function addResolversFor(uint ein, address[] memory resolvers) override public{
        for( uint32 i = 0; i < resolvers.length;i++){
            registry[ein].providers.insert(resolvers[i]);
            emit ResolverAdded(msg.sender, ein, resolvers[i]);       
        }
    }
    function removeResolvers(address[] memory resolvers) override public{
        for( uint32 i = 0; i < resolvers.length;i++){
            registry[einadd[msg.sender]].providers.remove(resolvers[i]);
            emit ResolverRemoved(msg.sender, einadd[msg.sender], resolvers[i]);
        }
    }
    function removeResolversFor(uint ein, address[] memory resolvers) override public{
        for( uint32 i = 0; i < resolvers.length;i++){
            registry[ein].providers.remove(resolvers[i]);
            emit ResolverRemoved(msg.sender, einadd[msg.sender], resolvers[i]);
        }
    }
    function triggerRecoveryAddressChange(address newRecoveryAddress) override public{
        address oldaddre = registry[einadd[msg.sender]].recoveryAddress;
        registry[einadd[msg.sender]].recoveryAddress = newRecoveryAddress;
        emit RecoveryAddressChangeTriggered(msg.sender, einadd[msg.sender], oldaddre, newRecoveryAddress);
    }
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) override public{
        address oldaddre = registry[ein].recoveryAddress;
        registry[ein].recoveryAddress = newRecoveryAddress;
        emit RecoveryAddressChangeTriggered(msg.sender, ein, oldaddre, newRecoveryAddress);
    }
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp) override public{
          require(
            isSigned(
                registry[ein].recoveryAddress,
                keccak256(
                    //abi.encodePacked(address(this),timestamp
                    "Hello How are you?"
                ),
                v, r, s
            ),
            "Permission denied."
        );
        address [] memory old = registry[ein].associatedAddresses.members;
        if(timestamp + 2 weeks < (block.timestamp)){
            for (uint i = 0; i < registry[ein].associatedAddresses.length();i++){
                delete einadd[registry[ein].associatedAddresses.members[i]];
            }
            delete registry[ein].associatedAddresses;
            delete registry[ein].providers;
            registry[ein].associatedAddresses.insert(newAssociatedAddress);
            emit RecoveryTriggered(msg.sender, ein, old, newAssociatedAddress);
        }
    }
    function triggerDestruction(uint ein, address[] memory firstChunk, address[] memory lastChunk, bool clearResolvers) override public{
        identity storage _identity = registry[ein];

        // ensure that the msg.sender was an old associated address for the referenced identity
        address[1] memory middleChunk = [msg.sender];
        require(
            keccak256(
                abi.encodePacked(firstChunk, middleChunk, lastChunk)
            ) == keccak256(abi.encodePacked(_identity.associatedAddresses.members)),
            "Cannot destroy an EIN from an address that was not recently removed from said EIN via recovery."
        );

        for(uint i = 0; i<_identity.associatedAddresses.length();i++){
            delete einadd[registry[ein].associatedAddresses.members[i]];        
        }
        delete registry[ein].associatedAddresses;
        delete registry[ein].providers;
        if (clearResolvers) delete registry[ein].resolvers;
        emit IdentityDestroyed(msg.sender, ein, _identity.recoveryAddress, clearResolvers);
        registry[ein].recoveryAddress = address(0);

    }

}