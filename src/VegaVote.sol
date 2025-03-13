pragma solidity ^0.8.11;

import {ERC20} "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} "@openzeppelin/contracts/access/Ownable.sol";

contract VegaVote is ERC20, Ownable {
    constructor(initSupply) ERC20("VegaVote", "VVT") Ownable(msg.sender) {
        _mint(msg.sender, initSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
