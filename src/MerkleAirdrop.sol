// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/*
 * @author: 0xError
 * @notice: This contract is a Merkle airdrop contract that allows you to airdrop tokens to a list of addresses
 */
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    /* ============= ERRORS ============= */
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /* ============= STATE VARIABLES ============= */
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /* ============= EVENTS ============= */
    event AirdropClaimed(address indexed account, uint256 amount);

    /* ============= CONSTRUCTOR ============= */
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /* ============= FUNCTIONS ============= */
    /*
     * @notice: This function is used to claim the airdrop
     * @param account: The address of the account that is claiming the airdrop
     * @param amount: The amount of tokens that the account is claiming
     * @param merkleProof: The merkle proof of the account
     * @param v: The v parameter of the signature
     * @param r: The r parameter of the signature
     * @param s: The s parameter of the signature
     */
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Check if the account has already claimed the airdrop
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // check the signature
        if (!_isValidSignature(account, getMessage(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
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

    function getMessage(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    /* ============= INTERNAL FUNCTIONS ============= */
    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    /* ============= GETTERS ============= */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
