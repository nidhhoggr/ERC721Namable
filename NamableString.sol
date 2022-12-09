// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Namable {

    mapping (string => bool) private _nameReserved;

    event NameChange (uint256 indexed tokenId, string newName);
    event BioChange (uint256 indexed tokenId, string bio);

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

    function isNameReserved(string memory nameString) public view returns (bool) {
        return _nameReserved[toLower(nameString)];
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

    function toLower(string memory str) public pure returns (string memory result) {
        assembly {
            let length := mload(str)
            if length {
                result := add(mload(0x40), 0x20)
                str := add(str, 1)
                let flags := shl(add(70, shl(5, false)), 67108863)
                let w := not(0)
                for { let o := length } 1 {} {
                    o := add(o, w)
                    let b := and(0xff, mload(add(str, o)))
                    mstore8(add(result, o), xor(b, and(shr(b, flags), 0x20)))
                    if iszero(o) { break }
                }
                result := mload(0x40)
                mstore(result, length)
                let last := add(add(result, 0x20), length)
                mstore(last, 0)
                mstore(0x40, and(add(last, 31), not(31)))
            }
        }
    }
}
