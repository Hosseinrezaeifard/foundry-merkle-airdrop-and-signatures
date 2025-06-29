// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/*
 * @author: 0xError
 * @notice: This contract is a ByteBuck token contract
 */
contract ByteBuckToken is ERC20, Ownable {
    constructor() ERC20("ByteBuckToken", "BBT") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
