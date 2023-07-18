// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Lottery {
    address public owner;
    uint public lotteryId;
    mapping(uint => address payable) public lotteryHistory;
    // We use payabele, so the address is able to recieve funds
    address payable[] public players;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }

    function enter() public payable {
        require(
            msg.value >= .01 ether,
            "Not enough ether to enter the lottery, please send .01 ether or more..."
        );
        //Adding address of new players to the array of players
        //We casted it to payable so we can get a payable address we our array is of payable address
        players.push(payable(msg.sender));
    }

    //Get current balance of fund in the contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    //Get list of players in the array
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    //To get the lit of previous lottery winners
    function getLotteryWinner(
        uint lottery
    ) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    //Using Pseudo-algorithm to generate random number
    function getRandomNumber() public view returns (uint) {
        //abi.encodePacked() is used to concatenate the two arguments, because keccak256() accepts only one argument
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    //Using our getRandonNumber function to pick a winner
    function pickWinner() public onlyWinner {
        uint index = getRandomNumber() % players.length;
        //Transfer the balance to the winner
        players[index].transfer(address(this).balance);
        lotteryHistory[lotteryId] = players[index];
        lotteryId++;

        //Reset the contract by creating a new array with lenght 0
        players = new address payable[](0);
    }

    modifier onlyWinner() {
        //To limit a functionality to only the owner of the contract
        require(msg.sender == owner);
        _;
    }
}
