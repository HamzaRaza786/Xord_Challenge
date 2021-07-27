//"SPDX-License-Identifier: UNLICENSED"
import './Erc721.sol';
contract Dex is ERCImplementation{
    mapping(uint=>address) products;
    mapping(uint=>uint) prilist; 
    modifier user(uint256 _tokenId){
        require((msg.sender == NFTowner[_tokenId] || NFTapprove[_tokenId] == msg.sender),"You don't have access");
        _;
    }
    function seller(uint _id, uint _price) user(_id) public {
        products[_id] = msg.sender;
        prilist[_id] = _price;
    }
    function buyer(uint _id, uint _price) public {
        require(products[_id] != address(0));
        require(prilist[_id] == _price, "Your Price is not equal to the given price");
        safeTransferFrom(products[_id],msg.sender,_id);
    }
}