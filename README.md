# VegaVote project contracts deploy

## VegaVote (VVT) contract
[check on etherscan](https://sepolia.etherscan.io/address/0x8c41a12e95f3936b2f8d6ebfd74bbcdfda808274)

## VoteResultNFT
[check on etherscan](https://sepolia.etherscan.io/address/0x5f9b1735e96c33e5131f33ca0f6f25e1ca2c927d)

## Polling
[check on ehterscan](https://sepolia.etherscan.io/address/0x90dd578e4f20b7476b7ecf4f42b1aa21ab04b8ed)

# how to run?

to run with local `VegaVoteToken`, (in my case `VegaVote`)
```
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --sig "run()"
```

to run with already existing in testnet `VegaVoteToken`
```
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --sig "run(address)" $VEGAVOTE_ERC_TOKEN
```

# cast test
[transaction](https://sepolia.etherscan.io/tx/0xa919efae86ceb1dd755e8093b4f779f579320d227fae18e58fc2c5c88db26fb6of) a function call `initVote()`
