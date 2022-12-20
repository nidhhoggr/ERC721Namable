# ERC721Namable

In this repository I seek to optimize Kongz implementation of ERC721Namable. The benchmarking is conducted using Foundry gas snapshots.

## Methodology

> 1. CyberKongz already stores their Kongz in a token struct mapping. Instead it's more optimal to also store the name and bio in this Kongz struct mapping.

### From 

```Solidity

    // declared in superclass ERC721Namable contract
    mapping(uint256 => string) public bio;
    mapping (uint256 => string) private _tokenName;

    // declared in Kongz contract
    struct Kong {
        uint256 genes;
        uint256 bornAt;
    }
    mapping(uint256 => Kong) public kongz;
```

### To
```Solidity
    struct Kong {
        uint256 genes;
        uint256 bornAt;
        string name;
        string bio;
    }
    mapping(uint256 => Kong) public kongz;
```

> 2. Next we declare methods changeName and changeBio to call superclass methods for name validation and reservation but ultimately store the result name/bio in the child class struct

```Solidity
    function changeName(uint256 _tokenId, string memory _newName) public {
        require(ownerOf(_tokenId) == _msgSender(), "InvalidOwner");
        Kongz storage kong = kongz[_tokenId];
        super.reserveName(_newName, kong.name);
        kong.name = _newName;
        emit NameChange(_tokenId, _newName);
    }

    //no validation happens in bio so theres nothing notable here
    function changeBio(uint256 _tokenId, string memory _bio) public {
        require(ownerOf(_tokenId) == _msgSender(), "InvalidOwner");
        Kongz storage kong = kongz[_tokenId];
        kong.bio = _bio;
        emit BioChange(_tokenId, _bio);
    }
```

> 3. Last we use a bytes32 mapping instead of a string mapping to check if the names are reserved by using assembly bytes conversion instead of the toLower method

### From
```Solidity
    mapping (string => bool) private _nameReserved;

    function reserveName(string memory newName, string memory oldName) internal {

        require(validateName(newName), "InvalidNewName");
        bool isEqual;
        assembly {
            isEqual := eq(keccak256(add(newName, 0x20), mload(newName)), keccak256(add(oldName, 0x20), mload(oldName)))
        }
        require(!isEqual, "NameMustBeDifferent");
        require(!isNameReserved(newName), "NameAlreadyReserved");

        // If already named, dereserve old name
        if (bytes(oldName).length > 0) {
             _nameReserved[toLower(oldName)] = false;
        }
        _nameReserved[toLower(newName)] = true;
    }
```

### To

```Solidity
    mapping (bytes32 => bool) private _nameReserved;

    function reserveName(string memory newName, string memory oldName) internal {

        require(validateName(newName), "InvalidNewName");
        bool isEqual;
        assembly {
            isEqual := eq(keccak256(add(newName, 0x20), mload(newName)), keccak256(add(oldName, 0x20), mload(oldName)))
        }
        require(!isEqual, "NameMustBeDifferent");
        require(!isNameReserved(newName), "NameAlreadyReserved");

        // If already named, dereserve old name
        if (bytes(oldName).length > 0) {
             _nameReserved[toBytes(oldName)] = false;
        }
        _nameReserved[toBytes(newName)] = true;
    }
```

> 4. Next we just get rid of all `string memory` parameters and used bytes32 instead ommiting the need for toBytes function calls when storing `_nameReserved`. Additionally custom errors save several thousand on deployment costs.

```
    function reserveName(bytes32 newName, bytes32 oldName) internal {

        if(!validateName(newName)) revert InvalidNewName();
        if(newName == oldName) revert NameMustBeDifferent(); 
        if(isNameReserved(newName)) revert NameAlreadyReserved();

        // If already named, dereserve old name
        if (oldName[0] != 0) {
             _nameReserved[oldName] = false;
        }
        _nameReserved[newName] = true;
    }
```

[Relevant git commit](https://github.com/nidhhoggr/ERC721Namable/commit/b9bfb04296ffe35be89b6fdde60b358db83eec2e)

## Files

### src/ERC721Namable/

The Kongz original implementation for reference purposes.

### src/NamableUsingString/

A new superclass to handle name reservation with the optimization described in step 2.

### src/NamableUsingBytes/

A new superclass to replace string mapping with bytes32 mapping with the optimization described in step 3.

## Benchmarking

In debugging transactions I was able to deduct that the Bytes32 mapping implementation saved up to several thousand wei in gas costs depending on the method called. Not the deployment costs increased from ~50k when changing reserveName from internal to public for easier testing.

### Original Kongz ERC721Namable
```
DudezERC721NamableTest:testChangeAndGetName() (gas: 74545)
DudezERC721NamableTest:testChangeAndGetNameEmpty() (gas: 9287)
DudezERC721NamableTest:testChangeAndGetReserved() (gas: 72002)
DudezERC721NamableTest:testChangeAndGetReservedEmpty() (gas: 10146)
DudezERC721NamableTest:testChangeBio() (gas: 83083)
DudezERC721NamableTest:testChangeName() (gas: 71405)
DudezERC721NamableTest:testDeploy() (gas: 1851949)
DudezERC721NamableTest:testValidateName() (gas: 11286)
```

### Using String mapping with an assembly-optimized toLower method
```
DudezNUSTest:testChangeAndGetName() (gas: 71347)
DudezNUSTest:testChangeAndGetNameEmpty() (gas: 9301)
DudezNUSTest:testChangeAndGetReserved() (gas: 69071)
DudezNUSTest:testChangeAndGetReservedEmpty() (gas: 8971)
DudezNUSTest:testChangeBio() (gas: 84968)
DudezNUSTest:testChangeName() (gas: 68193)
DudezNUSTest:testDeploy() (gas: 1457073)
DudezNUSTest:testValidateName() (gas: 10779)
```

### Using Bytes32 Mapping (Most optimal)
```
DudezNUBTest:testChangeAndGetName() (gas: 65595)
DudezNUBTest:testChangeAndGetNameEmpty() (gas: 7758)
DudezNUBTest:testChangeAndGetReserved() (gas: 64352)
DudezNUBTest:testChangeAndGetReservedEmpty() (gas: 7682)
DudezNUBTest:testChangeBio() (gas: 85012)
DudezNUBTest:testChangeName() (gas: 64573)
DudezNUBTest:testDeploy() (gas: 1260006)
DudezNUBTest:testValidateName() (gas: 10770)
```

