// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/*
 * @author: 0xError
 * @notice: This contract is a Merkle airdrop contract that allows you to airdrop tokens to a list of addresses
 */
contract MerkleAirdrop {
    /*
     * 1. We need to store a list of addresses which Some of them will be eligible for the airdrop
     * 2. But the for loop would be too expensive to find the eligible addresses, here's why
     * 3. So when someone tries to claim the airdrop, we need to check if they're eligible
     * 4. And in order to do that, we need to loop through the list of addresses and check if they're eligible
     * 5. But we don't want to loop through the list of addresses every time someone tries to claim the airdrop
     * 6. So we need to store the list of addresses in a Merkle tree
     * 7. And when someone tries to claim the airdrop, we need to check if they're eligible by checking if their address is in the Merkle tree
     */
}
