// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "../src/VegaVote.sol";

contract VegaVoteTest is Test {
    VegaVote public token;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        vm.prank(owner);
        token = new VegaVote();
    }

    function testInitialSupply() public {
        assertEq(token.balanceOf(owner), 1_000_000 * 10 ** token.decimals());
    }

    function testMint() public {
        vm.prank(owner);
        token.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
    }

    function test_RevertWhen_MintNotOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        token.mint(user, 100 ether);
    }
}
