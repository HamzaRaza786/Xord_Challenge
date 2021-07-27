pragma solidity 0.8.6;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract Task1 is Ownable{
    using SafeMath for uint;
    uint co = 0;
    struct obje{
        uint id;
        string name;
    }
    struct items{
        uint id;
        string task;
        bool state;
    }
    mapping (uint => obje) store;
    mapping (uint => items) list;
    function storeobj(uint id,string memory name) public{
        store[id] = obje(id,name);
    }
    function retriveobj(uint id) public view returns (string memory){
        return store[id].name;
    }
    function add(uint x) public view returns (uint){
        x = x.add(1);
        return x;
    }
    function todoadd(uint id,string memory task,bool state) public onlyOwner{
        list[id] = items(id,task,state);
    }
    function toggle(uint id) public onlyOwner{
        list[id].state = !list[id].state;
    }
    function display(uint id) public view returns (items memory){
        return list[id];
    }
}