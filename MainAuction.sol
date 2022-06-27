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

   

    // Auction[] public auctions;
    mapping(uint => Auction) public auctions;

    event AuctionCreated(
        uint auctionId,
        string assetName,
        string assetDetail,
        uint startPrice,
        address assetOwner,
        uint auctionDuration 
    );

    
    //Array Mapping
        // stored all Auction data in arrray
        // Auction[] public auctions;

        Bidding[] public biddingList;
        // address bidding;


        // auctionOwned[] public auctionOwner;
        

        // // Mapping from owner to a list of owned auctions
        // mapping(address => uint[]) public auctionOwner;

    

     function createAuction( string memory _assetName, string memory _assetDetail, uint _auctionDuration) public payable {
       
        //increment id
        auctionCount ++;  
        
        // make sure the status of the auction
        if (msg.value == 0){
            revert("you need to enter the start price/deposit");
        }
        
        //create new contract
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
