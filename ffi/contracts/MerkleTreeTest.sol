pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "ds-test/test.sol";

contract MerkleTreeTest is Test {

    string filename;
    uint addressesLength;
    address[] addresses;
    bytes32 root;
    uint32[] proofsLength;
    bytes32[][] merkleProofs;

    function setMerkleTree(string memory _filename) internal {
        filename = _filename;
        merkleTreeSetup();
    }

    function merkleTreeSetup() internal {
        getAddresses();
        getMerkleRoot();
        getMerkleProofLength();
        getMerkleProofs();
    }



    function getAddresses() private {
        delete addresses;
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "../MerkleTreeProvider.py";
        inputs[2] = "output_addresses";
        inputs[3] = string.concat("../", filename);

        bytes memory res = vm.ffi(inputs);
        
        uint8 _offset = 20;
        bytes20 aux;
        for(uint i = 32; i <= res.length + 32 -_offset  ; i = i + _offset) {
            assembly {  
                aux:=mload(add(res,i))
            }
            addresses.push(address(aux));
        }
    }

    function getMerkleRoot() private{
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "../MerkleTreeProvider.py";
        inputs[2] = "output_merkle_root";
        inputs[3] = string.concat("../", filename);

        bytes memory res = vm.ffi(inputs);
        root  = abi.decode(res, (bytes32));
    }


    function getMerkleProofLength() private  {
        delete proofsLength;
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "../MerkleTreeProvider.py";
        inputs[2] = "output_merkle_proofs_length";
        inputs[3] = string.concat("../", filename);

        bytes memory res = vm.ffi(inputs);
        bytes32 aux;
        uint8 _offset = 4;
        for(uint i = 32; i <= res.length + 32 - _offset  ; i = i + _offset) {
            assembly {  
                aux:=mload(add(res,i))
            }
            proofsLength.push(uint32(bytes4(aux)));
   
        }
    }


    function getMerkleProofs() private {
        delete merkleProofs;
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "../MerkleTreeProvider.py";
        inputs[2] = "output_merkle_proofs";
        inputs[3] = string.concat("../", filename);

        bytes memory res = vm.ffi(inputs);

        bytes32 aux;
        uint offset = 0;
        
        for(uint256 i=0; i < proofsLength.length ; i++){
            bytes32[] memory proof = new bytes32[](proofsLength[i]);

            for(uint j = 0; j < proofsLength[i]; j++) {
                offset = offset + 32;  
                assembly {
                    aux:=mload(add(res,offset))
                }
                proof[j]=bytes32(aux);
            }
            merkleProofs.push(proof);
        }
    }

    function getFilename() public view returns (string memory) { return  filename;}
}