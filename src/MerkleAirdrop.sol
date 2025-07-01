// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/*
 * @author: 0xError
 * @notice: This contract is a Merkle airdrop contract that allows you to airdrop tokens to a list of addresses
 */
contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    /* ============= ERRORS ============= */
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    /*
     * 1. We need to store a list of addresses which Some of them will be eligible for the airdrop
     * 2. But the for loop would be too expensive to find the eligible addresses, here's why
     * 3. So when someone tries to claim the airdrop, we need to check if they're eligible
     * 4. And in order to do that, we need to loop through the list of addresses and check if they're eligible
     * 5. But we don't want to loop through the list of addresses every time someone tries to claim the airdrop
     * 6. So we need to store the list of addresses in a Merkle tree
     * 7. And when someone tries to claim the airdrop, we need to check if they're eligible by checking if their address is in the Merkle tree
     */

    /* ============= STATE VARIABLES ============= */
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed; // Track the addresses that have already claimed the airdrop

    /* ============= EVENTS ============= */
    event AirdropClaimed(address indexed account, uint256 amount);

    /* ============= CONSTRUCTOR ============= */
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /* ============= FUNCTIONS ============= */
    /*
     * @notice: This function is used to claim the airdrop
     * @param account: The address of the account that is claiming the airdrop
     * @param amount: The amount of tokens that the account is claiming
     * @param merkleProof: The merkle proof of the account
     */
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        // Check if the account has already claimed the airdrop
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // Hash of the account and amount
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        // Verfiy the proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        // we have to add the account to the mapping to prevent double claiming
        // but notice that we need to do this before the transfer to prevent reentrancy attacks
        s_hasClaimed[account] = true;
        // Transfer the tokens to the account
        i_airdropToken.safeTransfer(account, amount);
        emit AirdropClaimed(account, amount);
    }
}
