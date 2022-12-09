// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A/contracts/ERC721A.sol";
import "./Namable.sol";

pragma solidity ^0.8.17;                                                                                

contract Dudez is ERC721A, Namable, Ownable  {

    struct Dude {
        uint256 bornAt;
        bool isManifested;
        string name;
        string bio;
    }

    mapping(uint256 => Dude) public dudez;

    constructor() ERC721A("Dudez", "DUDE") {}

    function changeName(uint256 _tokenId, string memory _newName) public {
        require(ownerOf(_tokenId) == _msgSender(), "InvalidOwner");
        Dude storage dude = dudez[_tokenId];
        super.reserveName(_newName, dude.name);
        dude.name = _newName;
        emit NameChange(_tokenId, _newName);
    }

    function changeBio(uint256 _tokenId, string memory _bio) public {
        require(ownerOf(_tokenId) == _msgSender(), "InvalidOwner");
        Dude storage dude = dudez[_tokenId];
        dude.bio = _bio;
        emit BioChange(_tokenId, _bio);
    }
}
