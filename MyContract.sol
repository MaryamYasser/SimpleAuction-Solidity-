pragma solidity >=0.7.0 <0.9.0;

contract SimpleAuction{
    //parameters of auction
    address payable public beneficiary;
    uint public auctionEndTime;

    //state of auction
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;
    bool ended = false;
    
    event HighestBidIncrease(address bidder, uint amount); //was there an increase
    event AuctionEnded(address winner, uint amount); //who is the winner and what is the amount

    constructor(uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable{
        if(block.timestamp > auctionEndTime){
            revert("Auction has ended");
        }

        if (msg.value <= highestBid){
            revert("There is already a higher or equal bid");
        }

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender,msg.value);




    }

    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];

        if(amount > 0){
            pendingReturns[msg.sender] = 0; //so that sender can't call it again
            if(!payable(msg.sender).send(amount)){ //send returns false if it fails
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
       return true;
    }
    function auctionEnd() public{
        if(block.timestamp < auctionEndTime){
            revert("Auction has not ended");
        }

        if(ended){
            revert("Function Auction Ended has already been called");
        }

        ended = true;
        emit AuctionEnded(highestBidder,highestBid);

        beneficiary.transfer(highestBid);

    }
}