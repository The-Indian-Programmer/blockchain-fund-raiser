// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract TransferFund {
    // Errors
    error TransterAmount__InsufficientAmount();
    error TransterAmount__NameRequired();
    error TransterAmount__NotSentAnyAmount();

    // Events
    event AmountAdded(address sender, uint256 amount, uint256 timestamp);
    event AmountWithDrawn(address sender, uint256 amount, uint256 timestamp);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "TransferFund__OnlyOwner");
        _;
    }

    // State variables
    address public owner;

    enum WithDrawnBy {
        NONE,
        USER,
        OWNER
    }

    struct AmountSender {
        string name;
        uint256 amount;
        address sender;
        uint256 timestamp;
        WithDrawnBy withDrawnBy;
    }

    AmountSender[] senders;

    constructor() {
        owner = msg.sender;
    }

    // Function to send amount to the contract
    function payAmount(string memory name) public payable {
        if (msg.value <= 0) revert TransterAmount__InsufficientAmount();
        if (bytes(name).length <= 0) revert TransterAmount__NameRequired();

        AmountSender memory newSender = AmountSender({
            name: name,
            amount: msg.value,
            sender: msg.sender,
            timestamp: block.timestamp,
            withDrawnBy: WithDrawnBy.NONE
        });
        senders.push(newSender);

        emit AmountAdded(msg.sender, msg.value, block.timestamp);
    }

    // Function to get the total amount
    function getTotalAmount() public view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < senders.length; i++) {
            totalAmount += senders[i].amount;
        }
        return totalAmount;
    }

    // function to withdraw the amount from the contract
    function withDrawAmount() public onlyOwner() returns(bool) {
        uint256 balances = address(this).balance;
        if (balances <= 0) revert TransterAmount__InsufficientAmount();

        payable(owner).transfer(balances);

        for (uint i = 0; i < senders.length; i++) {
            if (senders[i].withDrawnBy == WithDrawnBy.NONE) {
                senders[i].withDrawnBy = WithDrawnBy.OWNER;
            }
        }

        emit AmountWithDrawn(owner, balances, block.timestamp);
        return true;
    }


    // Function to withdraw the amount by the sender
    function withDrawYourAmount() public returns(bool) {
        uint256 balances = address(this).balance;
        if (balances <= 0) revert TransterAmount__InsufficientAmount();
        uint256 myAmount = 0;

        for (uint i = 0; i < senders.length; i++) {
            if (senders[i].sender == msg.sender && senders[i].withDrawnBy == WithDrawnBy.NONE) {
                myAmount += senders[i].amount;
            }
        }

        if (myAmount <= 0) revert TransterAmount__NotSentAnyAmount();

        payable(msg.sender).transfer(myAmount);

        for (uint i = 0; i < senders.length; i++) {
            if (senders[i].sender == msg.sender && senders[i].withDrawnBy == WithDrawnBy.NONE) {
                senders[i].withDrawnBy = WithDrawnBy.USER;
            }
        }

        emit AmountWithDrawn(msg.sender, myAmount, block.timestamp);
        return true;
    }

    // Function to get the total amount by the sender
    function getTotalAmountBySender() public view returns (uint256) {
        uint256 totalAmount = 0;    
        for (uint256 i = 0; i < senders.length; i++) {
            if (senders[i].sender == msg.sender && senders[i].withDrawnBy == WithDrawnBy.NONE) {
                totalAmount += senders[i].amount;
            }
        }
        return totalAmount;
    }

    // function to get all the sender and amount
    function getAllSenders() public view returns (AmountSender[] memory) {
        return senders;
    }

    // function to get the address of the contract
    function getAddress() public view returns (address) {
        return address(this);
    }

    // function to get the balance of the contract owner
    function getBalance() public view returns (uint256) {
        return address(owner).balance;
    }

    // function to get the address of owner
    function getOwner() public view returns (address) {
        return owner;
    }
}
