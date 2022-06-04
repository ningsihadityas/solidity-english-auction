pragma solidity >=0.7.0 <0.9.0;


contract AuctionCreator{
    Auction[] public auctions;

    function createAuction() public{
        Auction auction = new Auction(msg.sender);
        auctions.push(auction);
        
    }
}
