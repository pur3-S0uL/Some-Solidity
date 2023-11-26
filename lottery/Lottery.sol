// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LottertManagment{
    address payable manager = payable (msg.sender);
    address[] public participants;
    
    event Bought(address _buyer,uint _amount);
    event Winner(address _winner,uint _prize);


    modifier Restriction(){
        require(msg.sender == manager,"You are not the Manager.");
        _;
    }

    function viewBalance() public view Restriction() returns(uint) {
        return address(this).balance;
    }

    function getTicket() public payable {
        require(msg.value > 0.005 ether,"Insufficient amount to get into the lottery.");
        participants.push(msg.sender);
    }

    function getWinner(uint _index) public Restriction() {
        payable(participants[_index]).transfer(address(this).balance);
        emit Winner(participants[_index], address(this).balance);
    }

}
