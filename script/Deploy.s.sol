pragma solidity ^0.8.11;

import {Script} from "forge-std/Script.sol";
import {VegaVote} from "../src/VegaVote.sol";
import {VoteResultNFT} from "../src/VegaNFT.sol";
import {Polling} from "../src/Polling.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        VegaVote vegatoken = new VegaVote();
        VoteResultNFT nft = new VoteResultNFT();
        Polling poll = new Polling(address(vegatoken), address(nft));

        vm.stopBroadcast();
    }
}
