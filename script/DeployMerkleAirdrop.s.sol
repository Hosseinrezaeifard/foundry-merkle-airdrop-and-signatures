// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {ByteBuckToken} from "../src/ByteBuckToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_initialSupply = 25 * 1e18 * 4;

    function run() external returns (MerkleAirdrop, ByteBuckToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop()
        public
        returns (MerkleAirdrop, ByteBuckToken)
    {
        vm.startBroadcast();
        ByteBuckToken token = new ByteBuckToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(address(token))
        );
        token.mint(token.owner(), s_initialSupply);
        /* 
            a scenario in which we need approval, because in this scenario we're having the token contract pull the tokens from the owner's wallet
            token.approve(address(this), s_initialSupply);
            token.transferFrom(token.owner(), address(airdrop), s_initialSupply);
        */
        token.transfer(address(airdrop), s_initialSupply);
        vm.stopBroadcast();
        return (airdrop, token);
    }
}
