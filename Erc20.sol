//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
interface Erc20{
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function totalSupply()  external view returns (uint256);
    function balanceOf(address _owner)  external view returns (uint256 balance);
    function transfer(address _to, uint256 _value)  external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)  external  ;
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}
contract Task1 is Erc20{
    using SafeMath for uint256;
    uint total = 1000000;
    mapping(address=>uint256) bal;
    mapping(address=>mapping(address=>uint256)) transcheck;
    function totalSupply() override external view returns (uint256){
        return total;
    }
    function balanceOf(address _owner)  override external view returns (uint256 balance){
        return bal[_owner];
    }
    function transfer(address _to, uint256 _value)  override external returns (bool success){
        require(bal[msg.sender] >= _value,"Insufficient Balance");
        bal[_to].add(_value);
        bal[msg.sender].sub(_value);
        emit Transfer(msg.sender,_to,_value);
        return bal[_to] > _value;
    }
    function transferFrom(address _from, address _to, uint256 _value) override external{
        require(transcheck[_from][msg.sender] >= _value,"Inavlid Transaction -Not Authorize or -Not enough balance");
        bal[_to].add(_value);
        bal[msg.sender].sub(_value);
        emit Transfer(msg.sender,_to,_value);
    }
    function approve(address _spender, uint256 _value) override external returns (bool success){
            transcheck[_spender][msg.sender] = _value;
            emit Approval(msg.sender,_spender,_value);
            return true;
    }
    function allowance(address _owner, address _spender) override external view returns (uint256 remaining){
        return transcheck[_spender][_owner];
    }


}