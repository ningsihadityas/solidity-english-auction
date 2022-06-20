//pragma solidity ^0.4.17;


pragma solidity >=0.7.0 <0.9.0;

import "./Bidding.sol";



contract MainAuction{
    uint public auctionCount = 0;
    address payable assetOwner;
    uint assetId;
 
    // enum State {NotStarted, Running, Ended}

    struct Auction {
        uint auctionId;
        string assetName;
        string assetDetail;
        uint startPrice;
        address assetOwner;
        uint ownerDeposit;
        uint auctionDuration;

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
        address assetOwner,
        uint ownerDeposit,
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

    

     function createAuction( string memory _assetName, string memory _assetDetail, uint _startPrice, uint _auctionDuration) public payable {
       
        
       // auctions[auctionCount] = Auction(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender);
        
        require(msg.value == _startPrice, 'deposite must be same as start price');
        //create new contract
        Bidding bidding = (new Bidding){value: msg.value}(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender, msg.value, (block.timestamp + (_auctionDuration*60)));
        // saving address of new contract to bidding array
        biddingList.push(bidding); 

        

        //stored value to auctions struct
        auctions[auctionCount] = Auction(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender, msg.value, (block.timestamp + (_auctionDuration*60)));     
        // *60 because block.timestamp are on seconds 
        
        //calling auction created event 
        emit AuctionCreated(auctionCount, _assetName, _assetDetail, _startPrice, msg.sender, msg.value, (block.timestamp + (_auctionDuration*60)));
        
        
        //increment id
        auctionCount ++;  
    }

    function returnAllAuctions() public view returns(Bidding[] memory){
        return biddingList;
    }

   
}