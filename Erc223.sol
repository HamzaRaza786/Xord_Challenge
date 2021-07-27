pragma solidity 0.8.6;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "./Erc20.sol";
contract ERC223Receiver{
    function tokenfallback(address _from, uint _value, bytes memory _data) public{
        
    }
}
contract ERC223 is Task1,ERC223Receiver{
    using SafeMath for uint;
    function transfer(address _to, uint256 _value)  override external returns (bool){
        require(bal[msg.sender] >= _value,"Insufficient Balance");
        bal[_to].add(_value);
        bal[msg.sender].sub(_value);
        emit Transfer(msg.sender,_to,_value);
        return bal[_to] > _value;
         uint size;
         assembly {
             size := extcodesize(_to)
         }
        if(size > 0){
            tokenfallback(msg.sender,_value,"");
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transfer(address _to, uint256 _value, bytes memory data)  external returns (bool){
         require(bal[msg.sender] >= _value,"Insufficient Balance");
        bal[_to].add(_value);
        bal[msg.sender].sub(_value);
        emit Transfer(msg.sender,_to,_value);
        return bal[_to] > _value;
         uint size;
         assembly {
             size := extcodesize(_to)
         }
        if(size > 0){
            tokenfallback(msg.sender,_value,data);
        }
        emit Transfer(msg.sender, _to, _value);
        return true;

    }
}
