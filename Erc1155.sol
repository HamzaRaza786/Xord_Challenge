//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.6;
interface ERC1155{
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
interface ERC1155TokenReceiver {
     function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);
     function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
contract Task4 is ERC1155,ERC1155TokenReceiver,ERC165{
    mapping(uint=>address) owner;
    mapping(address=>uint[]) owned;
    mapping(address=>mapping(uint=>uint)) coinValue;
    mapping (address=>mapping(address=>uint[])) approve;
    function find(uint256[] memory arr,uint256 val) internal pure returns (bool){
        for(uint i = 0;i<arr.length;i++){
            if(arr[i] == val){
                return true;
            }
        }
        return false;
    }
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) override public{
        require((find(approve[_from][msg.sender],_id) || msg.sender == _from) && _from == owner[_id] && (_to != address(0)) &&(balanceOf(_from,_id) < _value));
        owner[_id] = _to;
        coinValue[_to][_id] += _value;
        coinValue[_from][_id] -= _value;
        emit TransferSingle(msg.sender,_from,_to,_id,_value);
        uint size;
        assembly {
             size := extcodesize(_to)
         }
        if(size > 0){
           require(onERC1155Received(_to,_from,_id,_value,_data) == bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")),"Invalid");
        }
    }
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override external{
        require((isApprovedForAll(_from,msg.sender) == true || msg.sender == _from) && (_to != address(0)) && _ids.length == _values.length);
        for(uint i=0;i<_ids.length;i++){
            require(coinValue[_from][_ids[i]] > _values[i]);
            owner[_ids[i]] = _to;
            coinValue[_to][_ids[i]] += _values[i];
            coinValue[_from][_ids[i]] -= _values[i];
        }
        emit TransferBatch(msg.sender,_from,_to,_ids,_values);
        uint size;
        assembly {
             size := extcodesize(_to)
         }
        if(size > 0){
           require(onERC1155BatchReceived(_to,_from,_ids,_values,_data) == bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)")),"Invalid");
        }
    }
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) override public view returns (uint256[] memory){
            uint256[] memory array;
            for(uint i = 0; i < _owners.length;i++){
                for(uint j = 0; j < _ids.length;_ids.length){
                    array[i + j] = coinValue[_owners[i]][_ids[i]];
                }
            }
            return array;
    }
    function balanceOf(address _owner, uint256 _id) override public view returns (uint256){
        return coinValue[_owner][_id];
    }
    function setApprovalForAll(address _operator, bool _approved) override public{
          if(_approved == true){
              for(uint i = 0;i < owned[msg.sender].length;i++){
                  approve[msg.sender][_operator][i] = coinValue[msg.sender][owned[msg.sender][i]];
              }
          }
          else{
               delete approve[msg.sender][_operator];
          }
    }
    function isApprovedForAll(address _owner, address _operator) override public view returns (bool){
        for(uint i = 0;i < owned[_owner].length;i++){
                  if (approve[_owner][_operator][i] != coinValue[_owner][owned[_owner][i]]){
                      return false;
                  }
              }
        return true;
    }
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) override public returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override public returns(bytes4){
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
    function supportsInterface(bytes4 interfaceID) override public view returns (bool){
        return  interfaceID == 0x01ffc9a7 ||  interfaceID == 0x4e2312e0;
    }
}