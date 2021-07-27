//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.6;
interface ERC721{
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}
contract ERCImplementation is ERC721{
    mapping(address=>uint[]) NFT;
    mapping(uint=>address) NFTowner;
    mapping(uint=>address) NFTapprove;
    mapping(address=>mapping(address=>uint)) operator;
    modifier checkAuthorization(address _from, address _to, uint256 _tokenId){
        require(msg.sender == _from && _from == NFTowner[_tokenId] && _to != address(0),"You don't have access");
        _;
    }
   function find(uint[] memory arr,uint256 _tokenId) internal pure returns (uint8){
       for(uint8 i =0;i < arr.length;i++){
           if(arr[i] == _tokenId){
               return i;
           }
       }
       return 0;
   }
    function balanceOf(address _owner) override external view returns (uint256){
        require(_owner != address(0), "Invalid address");
        return NFT[_owner].length;
    }
    function ownerOf(uint256 _tokenId) override external view returns (address){
        require(NFTowner[_tokenId] != address(0), "Invalid address");
        return NFTowner[_tokenId];
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) override external checkAuthorization(_from,_to,_tokenId) payable{
        uint from = NFT[_from][find(NFT[_from],_tokenId)];
        NFT[_to].push(_tokenId);
        delete NFT[_from][find(NFT[_from],_tokenId)];
        NFTowner[_tokenId] = _to;
        uint size;
         assembly {
             size := extcodesize(_to)
         }
        if(size > 0){
           require(onERC721Received(_to,_from,_tokenId,data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),"Invalid");
        }
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override checkAuthorization(_from,_to,_tokenId) public payable{
        uint from = NFT[_from][find(NFT[_from],_tokenId)];
        NFT[_to].push(from);
        delete NFT[_from][find(NFT[_from],_tokenId)];
        NFTowner[_tokenId] = _to;
        uint size;
         assembly {
             size := extcodesize(_to)
         }
        if(size > 0){
           require(onERC721Received(_to,_from,_tokenId,"") == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),"Invalid");
        }
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) override  external payable{
        require((msg.sender == _from || operator[_from][msg.sender] == _tokenId) && _from == NFTowner[_tokenId] && _to != address(0) ,"You don't have access");
       // uint from = NFT[_from][_tokenId];
        NFT[_to].push(_tokenId);
        delete NFT[_from][find(NFT[_from],_tokenId)];
        NFTowner[_tokenId] = _to;
    }
    function approve(address _approved, uint256 _tokenId) override external payable{
        require((msg.sender == NFTowner[_tokenId]) || (operator[NFTowner[_tokenId]][msg.sender] == _tokenId));
        operator[NFTowner[_tokenId]][_approved] = _tokenId;
        NFTapprove[_tokenId] = _approved;
    }
    function setApprovalForAll(address _operator, bool _approved) override external{
        require(_approved==true,"Not Approved");
        for(uint i =0;i < NFT[msg.sender].length;i++){
           operator[msg.sender][_operator] = NFT[msg.sender][i];
           NFTapprove[NFT[msg.sender][i]] = _operator;
       }
       emit ApprovalForAll(msg.sender,_operator,_approved);
    }
    function getApproved(uint256 _tokenId) override external view returns (address){
        if(NFTowner[_tokenId] != address(0))
            return NFTapprove[_tokenId];
        return address(0);
    }
    function isApprovedForAll(address _owner, address _operator) override external view returns (bool){
        return operator[_owner][_operator] > 0;
    }
    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes memory _data) public pure returns(bytes4){
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}