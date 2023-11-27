// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract OpenBid{
    address payable benificery;
    address highestBider;
    uint highestBid;
    uint auctionTime;
    bool ended;

    mapping (address => uint) pendingReturns;

    event HighestBid(address bidder,uint amount);
    event AuctionEnded(address bidder,uint amount);

    error AuctionAlreadyEnded();
    error AuctionNotEndedYet();
    error AuctionyEndAlreadyCalled();
    error BidNotHighEnough(uint highestBid);

    constructor(address payable beneficiaryAddress, uint auctionDuration) {
        benificery = beneficiaryAddress;
        auctionTime = block.timestamp + auctionDuration;
    }

    function bid() external payable {
        if (block.timestamp >= auctionTime) {
            revert AuctionAlreadyEnded();
        }

        if (msg.value <= highestBid){

            revert BidNotHighEnough(highestBid);
        }

        if (highestBid != 0)
        {
            pendingReturns[highestBider] += highestBid;
        }

        highestBider = msg.sender;
        highestBid = msg.value;

        emit HighestBid(msg.sender,msg.value);

    }

    function withdraw() external returns (bool){
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function end() external {
        if (block.timestamp < auctionTime) {
            revert AuctionNotEndedYet();
        }
        if (ended) {
            revert AuctionyEndAlreadyCalled();
        }

        ended = true;

        emit AuctionEnded(highestBider,highestBid);
        benificery.transfer(highestBid);
    }
}
