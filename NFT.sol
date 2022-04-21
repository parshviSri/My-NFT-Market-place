// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    address contractAddress;
    constructor(address marketplace) ERC721("Decentralised Market place", "DMP"){
        contractAddress = marketplace;

    }
    function createNFT(string memory tokenURI) public  returns (uint){
        _tokenId.increment();
        uint newTokenId = _tokenId.current();
        _mint(msg.sender,newTokenId);
        _setTokenURI(newTokenId,tokenURI);
        setApprovalForAll(contractAddress,true);
        return newTokenId;
    }
}
