//pragma solidity ^0.4.17;


pragma solidity >=0.7.0 <0.9.0;

import "./Bidding.sol";


contract MainAuction{
    uint public auctionCount = 0;
    address assetOwner;
    uint assetId;
    // enum State {NotStarted, Running, Ended}

    struct Auction {
        uint auctionId;
        string assetName;
        string assetDetail;
        uint startPrice;
        address assetOwner;
        address bidding;
        // bool purchased;
        // uint256 auctionDuration;
        // uint256 startPrice;
        // address owner;
        // bool active;
        // bool finalized;
        // State auctionState;
      //  Bidding[] biddingList;
    }

   

    // Auction[] public auctions;
    mapping(uint => Auction) public auctions;

    event AuctionCreated(
        uint auctionId,
        string assetName,
        string assetDetail,
        uint startPrice,
        address assetOwner
        // string biddingList
      //  address bidding
       
    );


    //Array Mapping
        // stored all Auction data in arrray
        // Auction[] public auctions;

        Bidding[] public biddingList;
        address bidding;


        // auctionOwned[] public auctionOwner;
        

        // // Mapping from owner to a list of owned auctions
        // mapping(address => uint[]) public auctionOwner;

        // auctionOwner[]
// auctionCount--;
     function createAuction( string memory _assetName, string memory _assetDetail, uint _startPrice) public {
       
        
       // auctions[auctionCount] = Auction(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender);
        

        Bidding bidding = new Bidding( auctionCount, _assetName, _assetDetail, _startPrice, msg.sender);
    
        biddingList.push(bidding); 
       
        auctions[auctionCount] = Auction(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender, bidding);      
        
        emit AuctionCreated(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender);
        auctionCount ++;
     
        // auctionOwner[assetOwner] =+ assetId;
    
       
    }

   
}