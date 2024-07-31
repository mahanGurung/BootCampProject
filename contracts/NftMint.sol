// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import"@openzeppelin/contracts@5.0.2/token/ERC721/ERC721.sol";
import"@openzeppelin/contracts@5.0.2/token/ERC721/extensions/ERC721Enumerable.sol";
import"@openzeppelin/contracts@5.0.2/token/ERC721/extensions/ERC721URIStorage.sol";


contract Mahan is ERC721, ERC721Enumerable, ERC721URIStorage {
uint256 private _nextTokenId;
uint MAX_SUPPLY = 10000;
constructor()
ERC721("Mahan Gurung", "MG")
{}


function safeMint(address to, string memory uri) public {
    uint256 tokenId = _nextTokenId++;
    require(tokenId <= MAX_SUPPLY, "You reached max limit.");
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
}


// The following functions are overrides required by Solidity.
function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Enumerable)returns (address){
    return super._update(to, tokenId, auth);
}


function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable){
    super._increaseBalance(account, value);
}

function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
}


function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool){
    return super.supportsInterface(interfaceId);
}

}