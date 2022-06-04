contract Auction{
    
    address payable public owner; 
    uint public auctionTime; //auction duration (in second)
    uint public startPrice;
   

    //current state 
    enum State { NotStarted, Running, Ended}
    State public auctionState;

    address public highestBidder;
    uint public highestBid;

    // bids mapping
    mapping(address => uint) public pendingReturns;

    // //aset owner mapping
    // mapping(address => uint) public depo;


    event HighestBidIncrease(address bidder, uint amount);
    // event AuctionEnded(address winner, uint amount);


    //there are 2 types of address: 1. eoa address 2.contract adress
    constructor(address ownerAddress) {
        owner = payable(ownerAddress);
       
    }

    function StartAuction(uint _biddingTime) payable public onlyOwner {
        require(msg.value != 0);
        auctionState = State.Running;
        auctionTime = block.timestamp + _biddingTime;
        startPrice = msg.value;
        //_startPrice; // in wei
      
    }

    //onlyowner modifier
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function bid() public payable{
        // check if the auction is still going
        if (block.timestamp > auctionTime) {
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
        if (msg.sender == owner){
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
    

    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];

        if (msg.sender == highestBidder){
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

    function auctionEnd() public onlyOwner{
        // check if the auction has ended
        if (block.timestamp < auctionTime){
            revert ("The auction is not ended yet");
        }
       
        // make sure the status of the auction
        if (auctionState == State.Ended){
            revert("The function auctionEnded has already been called");
        }

        auctionState = State.Ended;

        // emit  AuctionEnded(highestBidder, highestBid);

        owner.transfer(startPrice);
        owner.transfer(highestBid);
        // transfer is more safe then send, send will return false when it fails, while transfer didnt
    }
}
