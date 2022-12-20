// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract NamableUsingBytes {

    mapping (bytes32 => bool) private _nameReserved;

    event NameChange (uint256 indexed tokenId, bytes32 newName);
    event BioChange (uint256 indexed tokenId, string bio);

    error InvalidNewName();
    error NameMustBeDifferent();
    error NameAlreadyReserved();

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

    function isNameReserved(bytes32 nameString) public view returns (bool) {
        return _nameReserved[nameString];
    }

    function tokenNameByIndex(uint256 index) public virtual view returns (bytes32) {}

    function validateName(bytes32 str) public pure returns (bool){
        bytes1 lastChar;
        uint8 bLen;
        if (str[0] == 0x20) return false;//cannot contain leading space
        while (bLen < 32 && str[bLen] != 0) {
            bytes1 char = str[bLen];
            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces
            if (!(//not one of the following:
                (char >= 0x30 && char <= 0x39) || //between 9-0
                (char >= 0x41 && char <= 0x5A) || //between A-Z
                (char >= 0x61 && char <= 0x7A) || //between a-z
                (char == 0x20) //a space
            )) return false;
            lastChar = char;
            unchecked {
                bLen++;
            }
        }
        //finally must be 1 character && not have a trailing space
        return (bLen > 0 && lastChar != 0x20); 
    }
}
