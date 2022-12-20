// SPDX-License-Identifier: MIT

import "./NamableUsingBytes.sol";
import {ERC721A} from "./../../lib/ERC721A/contracts/ERC721A.sol";

pragma solidity ^0.8.17;

contract DudezBUS is NamableUsingBytes, ERC721A {

    struct Dude {
        uint256 bornAt;
        bool isManifested;
        bytes32 name;
        string bio;
    }

    mapping(uint256 => Dude) public dudez;

    constructor() ERC721A("Dudez", "DUDE") {}

    function changeName(uint256 _tokenId, bytes32 _newName) public {
        require(ownerOf(_tokenId) == _msgSenderERC721A(), "InvalidOwner");
        Dude storage dude = dudez[_tokenId];
        super.reserveName(_newName, dude.name);
        dude.name = _newName;
        emit NameChange(_tokenId, _newName);
    }

    function changeBio(uint256 _tokenId, string memory _bio) public {
        require(ownerOf(_tokenId) == _msgSenderERC721A(), "InvalidOwner");
        Dude storage dude = dudez[_tokenId];
        dude.bio = _bio;
        emit BioChange(_tokenId, _bio);
    }

    //for benchmarking name lookups
    function tokenNameByIndex(uint256 index) public view override returns (bytes32) {
        Dude storage dude = dudez[index];
        return dude.name;
    }

    //for testing
    function mint(address to) payable public {
        _mint(to, 1);
        dudez[_totalMinted()] = Dude(block.timestamp, false, "", "");
    }

    // ERC721A
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}