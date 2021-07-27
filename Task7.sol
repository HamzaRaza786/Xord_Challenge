pragma solidity 0.8.6;
contract Task7{
    function getMessageHash(address _to,uint amount,string memory message,uint nonce) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_to,amount,message,nonce));
    }
    function signMessage(bytes32 msgHash) public pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",msgHash));
    }
    function verifySig(address _signer,address _to,string memory message,uint8 amount, uint8 nonce,bytes memory _signature )
    public pure returns (bool){
            bytes32 msHas = getMessageHash(_to,amount,message,nonce);
            bytes32 ethsign = signMessage(msHas);
            return reciverSig(ethsign,_signature) == _signer;
    }
    function reciverSig(bytes32  ethsign, bytes memory _signature) public pure returns(address){
        (bytes32 r, bytes32 s, uint8 v) = splitSign(_signature);
        return ecrecover(ethsign,v,r,s);
    }
    function splitSign(bytes memory _signature) public pure returns (bytes32 r, bytes32 s, uint8 v){
        require(_signature.length == 65,"Invalid signature");
        assembly{
            r := mload(add(_signature,32))
            s := mload(add(_signature,64))
            v:= mload(add(_signature,96))
        }
    }
}
// Signing message through console using metamask through ethersjs as web3js is deprecated
// Code:
// ethereum.enable()
// hash = ....
// let privateKey= .....
// let wallet = new _ethers.Wallet(privateKey)
// let flatSig = await wallet.signMessage(//Your message);
// let contract = new _ethers.Contract(//Contract Address,[//function abi] , _ethers.getDefaultProvider('ropsten');
// contract.//your function name and parameters
//let contract = new _ethers.Contract("0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95",["function verifySig(address _signer,address _to,string memory message,uint8 amount, uint8 nonce,bytes memory _signature )"] ,_ethers.getDefaultProvider('ropsten'));
//contract.verifySig(privateKey,"0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","Coffee",123,1,flatSig)