pragma solidity 0.8.18;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20("MyToken", "MYT") {
    constructor(uint256 start_supply) {
        _mint(msg.sender, start_supply);
    }
}
