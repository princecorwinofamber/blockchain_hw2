pragma solidity 0.8.18;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CurrencyExchange {

    // Declare state variables of the contract
    uint256 private buy_price;
    uint256 private sell_price;
    // the next two fields are needed to prevent self destruct attack: https://solidity-by-example.org/hacks/self-destruct/
    uint256 private wei_balance;
    uint256 private token_balance;
    address public owner;
    IERC20 public token;

    // mapping (address => uint) public cupcakeBalances;

    constructor(address token_to_be_used) {
        owner = msg.sender;
        token = IERC20(token_to_be_used);
        wei_balance = 0;
        token_balance = 0;
    }
    
    // Set the price for which the token can be bought from our exchange
    function setBuyPrice(uint256 price) public {
        require(msg.sender == owner, "Only the owner can modify exchange rates.");
        buy_price = price;
    }

    // Set the price for which the token can be sold to our exchange
    function setSellPrice(uint256 price) public {
        require(msg.sender == owner, "Only the owner can modify exchange rates.");
        sell_price = price;
    }

    // Allow the owner to increase the smart contract's token balance
    function refillTokens(uint amount) public {
        require(msg.sender == owner, "Only the owner can refill.");
        require(token_balance + amount >= token_balance, "Overflow occured.");
        // cupcakeBalances[address(this)] += amount;
        token_balance += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    // Allow the owner to increase the smart contract's token balance
    function refillEther() external payable {
        require(msg.sender == owner, "Only the owner can refill.");
        require(wei_balance + msg.value >= wei_balance, "Overflow occured.");
        wei_balance += msg.value;
    }

    // Allow anyone to purchase token
    function purchase(uint amount) public payable {
        require(msg.value >= amount * buy_price, "Pay more!");
        require(token_balance >= amount, "Tokens ended in exchange. Come later!");
        require(wei_balance + amount * buy_price >= wei_balance, "Overflow occured.");
        token_balance -= amount;
        wei_balance += amount * buy_price;
        token.transfer(msg.sender, amount);
    }

    // Allow anyone to sell token
    function sell(uint amount) public payable {
        uint256 fixed_total_price = amount * sell_price;
        require(wei_balance >= fixed_total_price, "Ether ended in exchange. Come later!");
        require(token.balanceOf(msg.sender) >= amount, "You do not have enough tokens!");
        require(token_balance + amount >= token_balance, "Overflow occured.");
        token_balance += amount;
        wei_balance -= fixed_total_price;
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(fixed_total_price);
    }

    function kill() public {
        require(msg.sender == owner, "Only the owner can destroy.");
        uint256 tokens_to_be_withdrawn = token_balance;
        uint256 wei_to_be_withdrawn = wei_balance;
        token_balance = 0;
        wei_balance = 0;
        token.transfer(owner, tokens_to_be_withdrawn);
        payable(owner).transfer(wei_to_be_withdrawn);
        // selfdestruct(payable(owner)); // deprecated
    }
}

