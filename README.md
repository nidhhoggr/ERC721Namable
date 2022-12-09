# ERC721Namable

In this repository I seek to optimize Kongz' implementation of ERC721Namable.

## Methodology

1. CyberKongz already stroes all of their Kongz in a token struct mapping. Instead it's more optimal to store the name and bio in this Kongz struct mapping.

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

2. Next we declare methods changeName and changeBio to call superclass methods for name validation and reservation but ultimately store the result name/bio in the child class struct

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
        kong.bio = _newName;
        emit BioChange(_tokenId, _bio);
    }
```

3. Last we use a bytes32 mapping instead of a string mapping to check if the names are reserved by using keccak abi-encoding instead of the toLower method

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

## Files

### ERC721Namable.sol

The Kongz original implementation for reference purposes.

### NamableString.sol

A new superclass to handle name reservation with the optimization described in step 2.

### NamableBytes.sol

A new superclass to replace string mapping with bytes32 mapping with the optimization described in step 3.

### Dudez.sol

An example ERC721 token implementing the newly optimized Namable class.

## Benchmarking

In debugging transactions I was able to deduct that the Bytes32 mapping implementation saved up to several thousand wei in gas costs depending on the method called. Not the deployment costs increased from ~50k when changing reserveName from internal to public for easier testing.

```
String Mapping:
  Deployment: 618680
  isNameReserved: 25484
  validateName: 26352
  toLower: 23327
  Reserve Name: 59530
  Reserve Name (From Old): 62958
  New Reserve Name: 48268

Bytes Mapping:
  Deployment: 570300
  isNameReserved: 24712
  validateName: same
  toBytes: 22531
  Reserve Name: 50215
  Reserve Name (From Old):  50755
```

## Questions

Does this scale out to even further gas savings?
