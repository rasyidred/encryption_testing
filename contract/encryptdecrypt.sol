pragma solidity >=0.8.0;

contract encryptdecrypt{
    bytes32 public pesan= "Anjing";
    bytes32 public key = "Ini pesan";
    bytes32 public encrypted = pesan ^ key;
    bytes32 public decrypted = encrypted ^ key;

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
}