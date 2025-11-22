
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/TimeLockWallet.sol";

contract TimeLockWalletTest is Test {
    TimeLockWallet wallet;
    address owner = address(0xABCD);

    function setUp() public {
        vm.deal(owner, 1 ether);
        uint256 unlock = block.timestamp + 1 days;
        vm.prank(owner);
        wallet = new TimeLockWallet(unlock);
        vm.prank(owner);
        (bool sent,) = payable(address(wallet)).call{value: 0.5 ether}("");
        require(sent);
    }

    function testCannotWithdrawBeforeUnlock() public {
        vm.prank(owner);
        vm.expectRevert(bytes("Locked"));
        wallet.withdraw();
    }

    function testCanWithdrawAfterUnlock() public {
        vm.warp(block.timestamp + 2 days);
        vm.prank(owner);
        uint256 balBefore = owner.balance;
        wallet.withdraw();
        assertEq(owner.balance, balBefore + 0.5 ether);
    }
}   

