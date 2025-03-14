pragma solidity ^0.8.11;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {VegaVote} from "../src/VegaVote.sol";
import {VoteResultNFT} from "../src/VegaNFT.sol";
import {Polling} from "../src/Polling.sol";

contract DeployScript is Script {
    function run(address tokenAddress) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address token;
        VegaVote vegatoken;

        if (tokenAddress == address(0)) {
            vegatoken = new VegaVote();
            token = address(vegatoken);
            console.log("VegaVote deployed at:", token);
        } else {
            token = tokenAddress;
            console.log("Using existing VegaVote at Sepolia testnet:", token);
        }

        VoteResultNFT nft = new VoteResultNFT();
        Polling poll = new Polling(address(vegatoken), address(nft));
        nft.transferOwnership(address(poll));

        vm.stopBroadcast();

        console.log("VoteResultNFT deployed at:", address(nft));
        console.log("Polling deployed at:", address(poll));
    }
    function run() external {
        this.run(address(0));
    }
}
