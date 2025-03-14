// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "../src/VegaNFT.sol";

contract VoteResultNFTTest is Test {
    VoteResultNFT public nft;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        vm.prank(owner);
        nft = new VoteResultNFT();
    }

    function testMintNFT() public {
        VoteResultNFT.VoteResult memory info = VoteResultNFT.VoteResult({
            id: 1,
            description: "Test Vote",
            yess: 100,
            nos: 50,
            done: true
        });

        vm.prank(owner);
        nft.mint(user, info);

        assertEq(nft.ownerOf(1), user);
        (uint256 id, string memory description, uint256 yess, uint256 nos, bool done) = nft.tokenData(1);
        assertEq(description, "Test Vote");
        assertEq(yess, 100);
        assertEq(nos, 50);
        assertEq(done, true);
    }

    function test_RevertWhen_MintNotOwner() public {
        VoteResultNFT.VoteResult memory info = VoteResultNFT.VoteResult({
            id: 1,
            description: "Test Vote",
            yess: 100,
            nos: 50,
            done: true
        });

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user));
        nft.mint(user, info);
    }
}
