//"SPDX-License-Identifier: UNLICENSED" 
pragma solidity 0.8.6;
contract Task6{
    function hashgenerate(string memory f1, string memory f2) public pure returns(bytes32 result){
        bytes32 fasc = keccak256(abi.encodePacked(f1));
        bytes32 fasc2 = keccak256(abi.encodePacked(f2));
        if(fasc < fasc2){
            return keccak256(abi.encodePacked(f1,f2));
        }
        else{
            return keccak256(abi.encodePacked(f2,f1));
            
        }
    } 
}