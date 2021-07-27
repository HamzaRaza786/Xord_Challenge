pragma solidity 0.8.6;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Task4 is Ownable{
    uint balance = 0;
    uint start = 0;
    address Dp = 0xB56a23E41179c1f011d55dEa8f69928743e4d0Ff;

    function depoit() public payable{
        (bool success,) = Dp.call{value:msg.value}("");
        require(success,"Invalid Deposit");
        balance += msg.value;
    }
    modifier lag(){
        require(start==0 || block.timestamp > start + 1 minutes,"You need to wait for 1 minute");
        _; 
    }
    modifier valid(uint amount){
        require(balance >= amount,"Balance is ");
        _;
    }
    function withdraw(uint amount) public onlyOwner lag valid(amount){
        (bool success,) = msg.sender.call{value:amount}(" ");
        require(success,"Invalid Withdraw");
        balance -= amount;
        start = block.timestamp;
    }
    function balan() public view returns (uint){
        return address(this).balance;
    }
}






