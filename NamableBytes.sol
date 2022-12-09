// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Namable {

    mapping (bytes32 => bool) private _nameReserved;

    event NameChange (uint256 indexed tokenId, string newName);
    event BioChange (uint256 indexed tokenId, string bio);

    function reserveName(string memory newName, string memory oldName) internal {

        require(validateName(newName), "InvalidNewName");
        bool isEqual;
        //keccak256 unecessary for 25 char limited strings
        assembly {
            isEqual := eq(mload(add(newName, 32)),  mload(add(oldName, 32)))
        }
        require(!isEqual, "NameMustBeDifferent"); 
        require(!isNameReserved(newName), "NameAlreadyReserved");

        // If already named, dereserve old name
        if (bytes(oldName).length > 0) {
             _nameReserved[toBytes(oldName)] = false;
        }
        _nameReserved[toBytes(newName)] = true;
    }

    function isNameReserved(string memory nameString) public view returns (bool) {
        return _nameReserved[toBytes(nameString)];
    }

    function validateName(string memory str) public pure returns (bool){
        bytes memory b = bytes(str);
        uint256 bLen = b.length;
        
        if(bLen < 1) return false;
        if(bLen > 25) return false; // Cannot be longer than 25 characters
        if(b[0] == 0x20) return false; // Leading space
        
        bytes1 lastChar = b[bLen - 1];

        if (lastChar == 0x20) return false; // Trailing space

        for(uint i = 0; i<bLen;){
            bytes1 char = b[i];
            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces
            if (!isValid(char)) return false;
            lastChar = char;
            unchecked {
                ++i;
            }
        }

        return true;
    }

    function isValid(bytes1 char) internal pure returns (bool) {
        return (
            (char >= 0x30 && char <= 0x39) || //9-0
            (char >= 0x41 && char <= 0x5A) || //A-Z
            (char >= 0x61 && char <= 0x7A) || //a-z
            (char == 0x20) //space
        );
    }
    
    function toBytes(string memory str) internal pure returns (bytes32 result) {
        //return byte32(abi.encodePacked(str));
        //assembly is even cheaper than above: we know the string can only be 25 bytes based on the character limit
        assembly {
            result := mload(add(str, 32))
        }
    }
}
