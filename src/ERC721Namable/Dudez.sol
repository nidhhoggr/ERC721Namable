// SPDX-License-Identifier: MIT
import "./ERC721Namable.sol";

pragma solidity ^0.8.17;

contract Dudez is ERC721Namable {

    struct Dude {
        uint256 bornAt;
        bool isManifested;
    }

    mapping(uint256 => Dude) public dudez;

    constructor() ERC721Namable("Dudez", "DUDE") {}

    function changeName(uint256 _tokenId, string memory _newName) public override {
        require(ownerOf(_tokenId) == _msgSender(), "InvalidOwner");
        super.changeName(_tokenId, _newName);
    }

    function changeBio(uint256 _tokenId, string memory _bio) public override {
        require(ownerOf(_tokenId) == _msgSender(), "InvalidOwner");
        super.changeBio(_tokenId, _bio);
    }

    function mint(address to, uint256 tokenId) payable public {
        _mint(to, tokenId);
    }
}