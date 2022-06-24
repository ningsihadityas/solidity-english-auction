// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract MainAuction{
    uint public auctionCount = 0;
    address payable assetOwner;
    uint assetId;

    struct Auction {
        uint auctionId;
        string assetName;
        string assetDetail;
        uint startPrice;
        address assetOwner;
        uint auctionDuration;
    }

    mapping(uint => Auction) public auctions;

    event AuctionCreated(
        uint auctionId,
        string assetName,
        string assetDetail,
        uint startPrice,
        address assetOwner,
        uint auctionDuration 
    );


        Bidding[] public biddingList;
        // address bidding;


        // auctionOwned[] public auctionOwner;
        

        // // Mapping from owner to a list of owned auctions
        // mapping(address => uint[]) public auctionOwner;

    

     function createAuction( string memory _assetName, string memory _assetDetail, uint _auctionDuration) public payable {
        
         //increment id
        auctionCount ++;  
     
        // creating new smart contract
        Bidding bidding = (new Bidding){value: msg.value}(auctionCount, _assetName, _assetDetail, msg.value, msg.sender,(block.timestamp + (_auctionDuration*60)));
        // saving address of new contract to bidding array
        biddingList.push(bidding); 

        //stored value to auctions struct
        auctions[auctionCount] = Auction(auctionCount, _assetName, _assetDetail, msg.value, msg.sender, (block.timestamp + (_auctionDuration*60)));     
        // *60 because block.timestamp are on seconds 
        
        //calling auction created event 
        emit AuctionCreated(auctionCount, _assetName, _assetDetail, msg.value, msg.sender,  (block.timestamp + (_auctionDuration*60)));
        
        
       
    }

    function returnAllAuctions() public view returns(Bidding[] memory){
        return biddingList;
    }

   
}
