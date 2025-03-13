pragma solidity ^0.8.11;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VoteResultNFT is ERC721, Ownable {
    uint256 private tokenIdCount;
    struct VoteResult {
        uint256 id;
        string description;
        uint256 yess;
        uint256 nos;
        bool done;
    }

    mapping(uint256 => VoteResult) public tokenData;

    constructor() ERC721("VoteResult", "VRF") Ownable(msg.sender) {}

    function mint(address to, VoteResult memory info) external onlyOwner {
        tokenIdCount++;
        uint256 newTokenId = tokenIdCount;
        _safeMint(to, newTokenId);
        tokenData[newTokenId] = info;
    }
}
