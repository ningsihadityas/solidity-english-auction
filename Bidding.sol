pragma solidity >=0.7.0 <0.9.0;


contract Bidding  {

   // variable decralred
    address payable public assetOwner; 
    string public assetName;
    string public assetDetail;
    uint auctionId;
 
    enum State{NotStarted, Running, Ended}
    State public auctionState;

    uint startPrice;

    uint auctionDuration;


    address public highestBidder;
    uint public highestBid;

    // bids mapping
    mapping(address => uint) public pendingReturns;
   
    // event trigger
    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    //onlyowner modifier
    modifier onlyOwner(){
        require(msg.sender == payable(assetOwner));
        _;
    }

    //onlyWinner modifier
    modifier onlyWinner(){
        require(msg.sender == highestBidder);
        _;
    }

    event Received(address, uint);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

     //there are 2 types of address: 1. eoa address 2.contract adress
    constructor(uint _auctionId, string memory _assetName, string memory _assetDetail, uint _startPrice, address _assetOwner, uint _auctionDuration) payable{
        auctionId = _auctionId;
        assetName = _assetName;
        assetDetail = _assetDetail;
        startPrice = _startPrice;
        assetOwner = payable(_assetOwner);
        auctionState = State.Running;
        auctionDuration = _auctionDuration;
        auctionState = State.Running;
   
        // isActive = _isActive;
    }


    function bid() public payable{
        // check if the auction is still going
        if (block.timestamp > auctionDuration) {
            revert("The acution has already ended"); // revert is neded to stop the function(same as required)
        }
        // check if the bidding is higher than the start price
        if (msg.value <= startPrice ){
            revert("This bidding is bellow the start price");
        }
        // check if the bidding is higher than before
        if (msg.value <= highestBid ){
            revert("There is already higher bid");
        }

        // the owner can't join the bidding
        if (msg.sender == assetOwner){
            revert("you can't join the bidding");
        }

        //funds mapping so the user can get his money back when he lost
        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        //calling event
        emit HighestBidIncrease(msg.sender, msg.value);
    }

     function getBalance() public view returns(uint){
        return address(this).balance;
    }

     function getOwnerDeposite() public view returns(uint){
        return startPrice;
    }

   

    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];

        if (msg.sender == highestBidder){
            revert("you are the winner of this auction");
        }
        // make the pending returns to 0 everytime user click withdraw (avoid DAO)
        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            //if fail to sending money back
            if(!payable((msg.sender)).send(amount)){
                pendingReturns[msg.sender] = amount; //the money will back to the amount container
                return false;
            }
        }
        return true;

    }

    function auctionEnd() public onlyWinner{
        // check if the auction has ended
        if (block.timestamp < auctionDuration){
            revert ("The auction is not ended yet");
        }
       
        // make sure the status of the auction
        if (auctionState == State.Ended){
            revert("The function auctionEnded has already been called");
        }

        auctionState = State.Ended;

        // isActive = false;

        emit AuctionEnded(highestBidder, highestBid);

        payable(assetOwner).transfer(startPrice);
        payable(assetOwner).transfer(highestBid);
        // transfer is more safe then send, send will return false when it fails, while transfer didnt

    }

     function returnContents() public view returns(        
        string memory,
        uint,
        string memory,
        State
        ) {
        return (
            assetName,
            startPrice,
            assetDetail,
            auctionState
        );
    }

    // event BidSuccess(address _bidder, uint _auctionId);

   

    // // AuctionCanceled is fired when an auction is canceled
    // event AuctionCanceled(address _owner, uint _auctionId);

    // // AuctionFinalized is fired when an auction is finalized
    // event AuctionFinalized(address _owner, uint _auctionId);

    // event AuctionStarted(address _owner, uint _auctionId);

    
}



