// SPDX-License-Identifier

pragma solidity >=0.7.0 <0.9.0;



contract AuctionContract {
    
    // Array with all auctions
    Auction[] public auctions;

    // Mapping from auction index to user bids
    mapping(uint256 => Bid[]) public auctionBids;
    
    //NEW mapping pending return
    mapping(address => uint) public pendingReturns;

    //NEW mapping owner deposit/startprice
    // mapping(uint => uint) public ownerDeposit;

    // Mapping from owner to a list of owned auctions
    mapping(address => uint[]) public auctionOwner;

    // Bid struct to hold bidder and amount
    struct Bid {
        address bidder;
        uint256 amount;
    }

    string shippingDetail;

    // Auction struct which holds all the required info
    struct Auction {
        string assetName;
        string assetDescription;
        uint256 auctionDuration;
        uint256 startPrice;
        address assetOwner;
        bool active;
    }


    function getCount() public returns(uint) {
        return auctions.length;
    }


    function getBidsCount(uint _auctionId) public returns(uint) {
        return auctionBids[_auctionId].length;
    }

    function getAuctionsOf(address _assetOwner) public returns(uint[] memory) {
        uint[] memory ownedAuctions = auctionOwner[_assetOwner];
        return ownedAuctions;
    }

    function getCurrentBid(uint _auctionId) public returns(uint256, address) {
        uint bidsLength = auctionBids[_auctionId].length;
        // if there are bids refund the last bid
        if( bidsLength > 0 ) {
            Bid memory auctionWinner = auctionBids[_auctionId][bidsLength - 1];
            return (auctionWinner.amount, auctionWinner.bidder);
        }
        return (0, 0x0000000000000000000000000000000000000000);
    }

    function getAuctionsCountOfOwner(address _assetOwner) public  returns(uint) {
        return auctionOwner[_assetOwner].length;
    }

    function getAuctionById(uint _auctionId) public returns(
        string memory assetName,
        string memory assetDescription,
        uint256 auctionDuration,
        uint256 startPrice,
        address assetOwner,
        bool active) {

        Auction memory auc = auctions[_auctionId];
        return (
            auc.assetName, 
            auc.assetDescription,
            auc.auctionDuration, 
            auc.startPrice, 
            auc.assetOwner, 
            auc.active);
    }
    
   
    function createAuction( string memory _assetName, string memory _assetDescription, uint _auctionDuration) public payable {
        uint auctionId = auctions.length;
        Auction memory newAuction;
        newAuction.assetName = _assetName;
        newAuction.assetDescription = _assetDescription;
        newAuction.auctionDuration = block.timestamp + (_auctionDuration*60);
        newAuction.startPrice = msg.value;
        newAuction.assetOwner = msg.sender;
        newAuction.active = true;
        
        auctions.push(newAuction);        
        auctionOwner[msg.sender].push(auctionId);

        
        require(msg.value != 0);
        emit AuctionCreated(msg.sender, auctionId);
        

         
    }

    function finalizeAuction(uint _auctionId) payable public returns(bool) {
        Auction memory a = auctions[_auctionId];
        uint bidsLength = auctionBids[_auctionId].length;
        Bid memory auctionWinner = auctionBids[_auctionId][bidsLength - 1];
        

        // check if the auction has ended
        if( block.timestamp < a.auctionDuration ){revert("The auction is not ended yet");}
        
        // make sure the status of the auction
        if(a.active == false){
            revert("The function auctionEnded has already been called");
        }

        // make sure the status of the auction
         if(msg.sender != auctionWinner.bidder){
            revert("you are not the winner of this auction");
        }

        a.active = false;
        
        // update the auction
        auctions[_auctionId] = a;

        emit AuctionEndedWithWinner(_auctionId, auctionWinner.bidder, auctionWinner.amount);

        //send money to the asset owner
        payable(a.assetOwner).transfer(auctionWinner.amount);
        payable(a.assetOwner).transfer(a.startPrice);
           
        

        
          
    }

    function bidOnAuction(uint _auctionId) public payable {
        uint256 ethAmountSent = msg.value;

        // owner can't bid on their auctions
        Auction memory a = auctions[_auctionId];
        if(a.assetOwner == msg.sender) revert("The Owner cannot bid on their auction");

        // if auction is expired
        if( block.timestamp > a.auctionDuration ) revert();

        uint bidsLength = auctionBids[_auctionId].length;
        uint256 tempAmount = a.startPrice;
        Bid memory auctionWinner;

        // there are previous bids
        if( bidsLength > 0 ) {
            auctionWinner = auctionBids[_auctionId][bidsLength - 1];
            tempAmount = auctionWinner.amount;
        }

        // check if amound is greater than previous amount  
        if( ethAmountSent < tempAmount ){
            revert("There is already higher bid");
        }


        // insert bid 
        Bid memory newBid;
        newBid.bidder = msg.sender;
        newBid.amount = ethAmountSent;

         //funds mapping so the user can get his money back when he lost
        if (newBid.amount != 0){
            pendingReturns[newBid.bidder] += newBid.amount;
        }

        auctionBids[_auctionId].push(newBid);
        emit BidSuccess(msg.sender, _auctionId);

       
    }

    function withdraw(uint _auctionId) public returns(bool){
        uint amount = pendingReturns[msg.sender];
        uint bidsLength = auctionBids[_auctionId].length;
        Bid memory auctionWinner = auctionBids[_auctionId][bidsLength - 1];

        if (msg.sender == auctionWinner.bidder){
            pendingReturns[msg.sender] = 0;
            revert("you are the winner of this auction");
        }
        // make the pending returns to 0 everytime user click withdraw (avoid DAO)
        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            //if fail to sending money back
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount; //the money will back to the amount container
                return false;
            }
        }
        return true;

    }

    // stored shipping detail
    function submitShippingDetail(string memory _shippingDetail, uint _auctionId) public  {

        uint bidsLength = auctionBids[_auctionId].length;
        Bid memory auctionWinner = auctionBids[_auctionId][bidsLength - 1];

        Auction memory a = auctions[_auctionId];

         // check if the auction has ended
        if (block.timestamp < a.auctionDuration){
            revert ("The auction is not ended yet");
        }

        if (msg.sender != auctionWinner.bidder
        ){
            revert("you are not the winner of this auction");
        }

        shippingDetail = _shippingDetail;
    }

    // return value of shipping detail
    function getShippingDetail(uint _auctionId) public view returns (string memory){

         Auction memory a = auctions[_auctionId];

         if (msg.sender != a.assetOwner){
            revert("you are not the asset owner of this auction");
        }

        return shippingDetail;
    }


    event BidSuccess(address _bidder, uint _auctionId);

    // AuctionCreated is fired when an auction is created
    event AuctionCreated(address _assetOwner, uint _auctionId);

    // AuctionFinalized is fired when an auction is finalized
    event AuctionFinalized(address _bidder, uint _auctionId);

    event AuctionEndedWithWinner(uint auctionId, address winningBidder, uint256 amount);



    
}
