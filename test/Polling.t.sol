// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "../src/VegaVote.sol";
import "../src/VegaNFT.sol";
import "../src/Polling.sol";

contract PollingTest is Test {
    VegaVote public token;
    VoteResultNFT public nft;
    Polling public poll;
    address public owner = address(0x123);
    address public user = address(0x567);

    uint256 userCount = 5;
    address[] users = new address[](userCount);

    function setUp() public {
        vm.prank(owner);
        token = new VegaVote();

        vm.prank(owner);
        nft = new VoteResultNFT();

        vm.prank(owner);
        poll = new Polling(address(token), address(nft));

        vm.prank(owner);
        nft.transferOwnership(address(poll));

        for (uint256 i = 0; i < userCount; ++i) {
            users[i] = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, i)))));
            vm.prank(owner);
            token.mint(users[i], 100 ether); 
        }

        // for uniq user
        vm.prank(owner);
        token.mint(user, 100 ether); 
    }

    function testStakeTokens() public {
        vm.prank(owner);
        token.mint(user, 100 ether);

        vm.prank(user);
        token.approve(address(poll), 50 ether);

        vm.prank(user);
        poll.stakeTokens(50 ether, 2 * 365 days);

        (uint256 amount, , ) = poll.stakes(user);
        assertEq(amount, 50 ether);
    }

    function testVoteEmission() public {
        vm.prank(owner);
        poll.initVote("REWRITE coreutils to RUST :)?", 7 days, 100 ether);

        uint256 totalYes = 0;
        uint256 totalNo = 0;

        for (uint256 i = 0; i < userCount; ++i) {
            uint256 stakeDuration = ((i % 4) + 1) * 365;
            console.log("i is = ", i, " with stake dur = ", stakeDuration);

            vm.prank(users[i]);
            token.approve(address(poll), 50 ether);
            vm.prank(users[i]);
            poll.stakeTokens(50 ether, stakeDuration);

            bool voteChoice = i % 2 == 0;
            vm.prank(users[i]);
            poll.vote_emission(0, voteChoice);

            uint256 votingPower = 50 ether * (stakeDuration ** 2);
            console.log("power for ", i, " = ", votingPower);
            if (voteChoice) {
                totalYes += votingPower;
            } else {
                totalNo += votingPower;
            }
            console.log(i, " BLOCK TIME: ", block.timestamp);
        }

        vm.warp(block.timestamp + 8 days);
        // console.log(" BLOCK TIME: ", block.timestamp);

        vm.prank(owner);
        poll.endVote(0);

        (, , , uint256 yess, uint256 nos, Polling.PollState state) = poll.polls(0);

        assertEq(yess, totalYes, "'Yes' votes should match expected voting power");
        assertEq(nos, totalNo, "'No' votes should match expected voting power");
        assertEq(uint256(state), uint256(Polling.PollState.Over), "Vote should be over");
    }
    
    function testInitVote() public {
        vm.prank(owner);
        poll.initVote("REWRITE coreutils to RUST????? :)?", 7 days, 100 ether);

        (, , uint256 threshold, , , Polling.PollState state) = poll.polls(0);
        assertEq(threshold, 100 ether);
        assertEq(uint256(state), uint256(Polling.PollState.Active));
    }

    function test_RevertWhen_VoteEmissionNoStake() public {
        vm.prank(owner);
        poll.initVote("REWRITE coreutils to RUST????? :)?", 7 days, 100 ether);

        vm.prank(user);
        vm.expectRevert("User has no power to vote!");
        poll.vote_emission(0, true);
    }

    function testCannotStakeTwice() public {
        vm.startPrank(user);
        token.approve(address(poll), 100 ether);
        poll.stakeTokens(50 ether, 365 days);
        vm.expectRevert("Already staked");
        poll.stakeTokens(50 ether, 365 days);
        vm.stopPrank();
    }

    function testCannotStakeInvalidParams() public {
        vm.startPrank(user);
        token.approve(address(poll), 100 ether);
        vm.expectRevert("Invalid amount, must be > 0");
        poll.stakeTokens(0, 365 days);
        vm.expectRevert("Invalid duration, must be: 0 < dur <= 4");
        poll.stakeTokens(50 ether, 0);
        vm.expectRevert("Invalid duration, must be: 0 < dur <= 4");
        poll.stakeTokens(50 ether, 1461 days);
        vm.stopPrank();
    }
    function testCannotVoteAfterDeadline() public {
        vm.prank(owner);
        poll.initVote("REWRITE coreutils to RUST????? :)?", 7 days, 100 ether);
        vm.startPrank(user);
        token.approve(address(poll), 50 ether);
        poll.stakeTokens(50 ether, 365 days);
        vm.warp(block.timestamp + 8 days);
        vm.expectRevert("Voting period ended");
        poll.vote_emission(0, true);
        vm.stopPrank();
    }
}
