// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Upgraded is Ownable, ERC721("Upgraded", "UpNFT") {
    // Metadata attributes
    struct TokenMetaData {
        uint _tokenId;
        uint _timeStamp;
        string _url;
        address _creator;
        uint initialCostInEth;
    }

    // state variables
    uint tokenId;
    mapping(uint => uint) availableNFTs;
    mapping(address => mapping(uint => TokenMetaData)) tokensAtAddress;

    // initializing the number of NFTs;
    // 8 NFT worth 1 ETH, 8 NFT worth 2ETH, 4 NFT worth 3 ETH
    constructor(uint _tier1, uint _tier2, uint _tier3) {
        availableNFTs[1] = _tier1;
        availableNFTs[2] = _tier2;
        availableNFTs[3] = _tier3;
        // availableNFTs[4] = _tier1;
    }

    // event to return the available NFTs according to tiers
    event NumberOfNFTs(uint tier1, uint tier2, uint tier3);
    event MetaData(address user, uint _tokenId, TokenMetaData metadata);

    // function to check the availability of NFTs in the contract
    function getAvailableNFTs() public returns (uint, uint, uint) {
        emit NumberOfNFTs(availableNFTs[1], availableNFTs[2], availableNFTs[3]);
        return (availableNFTs[1], availableNFTs[2], availableNFTs[3]);
    }

    // Minting NFTs
    function mintNFT(address _to, string memory _url, uint _tier) public payable {
        require(availableNFTs[_tier] > 0, "No available NFTs in this tier!");
        require(msg.value/(1 ether) == _tier, "Incorrect payment");
        _safeMint(_to, tokenId);
        tokensAtAddress[_to][tokenId] = TokenMetaData(tokenId, block.timestamp, _url, _to, _tier);
        tokenId++;
        availableNFTs[_tier]--;

        emit NumberOfNFTs(availableNFTs[1], availableNFTs[2], availableNFTs[3]);
        emit MetaData(_to, tokenId, tokensAtAddress[_to][tokenId]);
    }

    // Upgrades to the contract

    // function to transfer a token from one address to another
    function transferToken(address _from, address _to, uint _tokenId) public {
        require(_from == msg.sender, "You cannot transfer tokens of other addresses!");
        require(tokensAtAddress[_from][_tokenId]._timeStamp != 0, "Invalid token id!");
        _transfer(_from, _to, _tokenId);
        tokensAtAddress[_to][_tokenId] = tokensAtAddress[_from][_tokenId];
        delete(tokensAtAddress[_from][_tokenId]);

        emit MetaData(_from, tokenId, tokensAtAddress[_from][_tokenId]);
        emit MetaData(_to, tokenId, tokensAtAddress[_to][_tokenId]);
    }

    // function to withdraw the balance amount in contract to a specific address
    // this function can only be used by the owner of the contract
    function withdrawAmount(address payable _to, uint _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Not enough funds!");
        _to.transfer(_amount);
    }
}