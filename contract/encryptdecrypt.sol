// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.8.0;

// pragma experimental ABIEncoderV2;

contract purewallet {

    struct accountProperties{ //Temporary data for mobile application
        uint256 money;
        uint totalBalance;
        bytes32 hashMoneyList;
        uint256 used;       
    }

    struct accountPropertiesPam{ //Permanent data for withdrawal purpose
        uint256[] money;
        uint256 totalBalance;
        bytes32 [] hashMoneyList;
        uint256 [] countIndex;
        uint256 used;
        uint256 time;
        bool withdrawBalanceRequested;
    }
    
    uint calculatedBalance;

    bytes32[] private allhash3256; //Hash3s for public verification
    // bytes32[] private allhash1;

    address payable owner = msg.sender;
    uint256 private time = block.timestamp;

    mapping (address => accountProperties) depositors;
    mapping (address => accountPropertiesPam) depositorsPam;


    string zza;
    string zzd;

    bool internal locked = false;

    event depositEvent(bytes32 encryptedHash, bytes32 _hash3);
    event withdrawalEvent(bytes32 _hash);

    uint256 [] private allCountIndex;
    uint256 count;
   
    function storeMoney (uint256 nom) payable public returns(bytes32 hash1, uint value){ //Deposit function
    require(depositorsPam[msg.sender].withdrawBalanceRequested == false, "You cannot deposit when you have requested to withdraw all");

    require(msg.value > 0, "include a value for offline transaction");
                
        bytes32 aaa = keccak256(abi.encodePacked(msg.value, block.timestamp-time, nom));
        zza = toHex(aaa);
        bytes32 aad = sha256(abi.encodePacked(zza));
        zzd = toHex(aad);
        bytes32 aae = sha256(abi.encodePacked(zzd));
        allhash3256.push(aae);         
        allCountIndex.push(count);

        accountPropertiesPam storage depositorPam = depositorsPam[msg.sender];
        depositorPam.countIndex.push(count);
        count++;        
        depositorPam.money.push(msg.value);
        depositors[msg.sender].money = msg.value;
        depositorPam.totalBalance += msg.value;
        calculatedBalance += msg.value;
        depositorPam.hashMoneyList.push(aaa); 
        depositors[msg.sender].hashMoneyList = aaa;

        // Encrypt the Hash1
        bytes32 key = keccak256(abi.encodePacked(msg.sender)); //make msg.sender as key
        bytes32 encryptedAAA = encryptDecrypt(aaa, key); //encrypt aaa (Hash1) and key
        
        // Emit the Encrypted-Hash1 and H1
        emit depositEvent(encryptedAAA, aae);        

        return (aaa, msg.value);
    }

    
    function toHex16 (bytes16 data) internal pure returns (bytes32 result) {
    result = bytes32 (data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000 |
          (bytes32 (data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64;
    result = result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000 |
          (result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32;
    result = result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000 |
          (result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16;
    result = result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000 |
          (result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8;
    result = (result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4 |
          (result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8;
    result = bytes32 (0x3030303030303030303030303030303030303030303030303030303030303030 +
           uint256 (result) +
           (uint256 (result) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 &
           0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 39);
    }

    function toHex (bytes32 data) private pure returns (string memory) {
        return string (abi.encodePacked ("0x", toHex16 (bytes16 (data)), toHex16 (bytes16 (data << 128))));
    }
    
    function withdrawNoAddress (address _address, bytes32 _hashMoney) public { //Withdrawal function

        require(!locked); //Reentrancy attack security
        locked = true;        
        address payable _to = payable(msg.sender);
        
        // transforms the address to key and encryptedHashMoney to Hash1
        // bytes32 key = genKey(_address);
        // bytes32 _hashMoney = encryptDecrypt(_encHashMoney, key);

        findUserPam(_address, _hashMoney);       
        uint b;
        if (depositorsPam[_address].hashMoneyList[depositorsPam[_address].used] == _hashMoney){
            uint a = depositorsPam[_address].money[depositorsPam[_address].used];
            b = depositorsPam[_address].countIndex[depositorsPam[_address].used];
            require (depositorsPam[_address].totalBalance >= a);
            depositorsPam[_address].hashMoneyList[depositorsPam[_address].used] = depositorsPam[_address].hashMoneyList[depositorsPam[_address].hashMoneyList.length - 1];
            depositorsPam[_address].hashMoneyList.pop();

            depositorsPam[_address].countIndex[depositorsPam[_address].used] = depositorsPam[_address].countIndex[depositorsPam[_address].hashMoneyList.length - 1];
            depositorsPam[_address].countIndex.pop();

            depositorsPam[_address].money[depositorsPam[_address].used] = depositorsPam[_address].money[depositorsPam[_address].money.length - 1];
            depositorsPam[_address].money.pop(); 
            
            calculatedBalance -= a;
            depositorsPam[_address].totalBalance -= a;
            _to.transfer(a); 
            
        } 

        bytes32 tt;
        for(uint i=0;i<allCountIndex.length;i++){ 
            if(allCountIndex[i] == b){ 
                allCountIndex[i] = allCountIndex[allCountIndex.length-1]; 
                allCountIndex.pop();
                tt = allhash3256[i];
                allhash3256[i] = allhash3256[allhash3256.length-1]; 
                allhash3256.pop();
                
            } 
        }

        emit withdrawalEvent(tt);

        locked = false; 
    }

    function sendMoney(address payable _address) payable public { //Send money directly when online
        require (_address != msg.sender);
        _address.transfer(msg.value); 
    }

   function viewAccountBalance () public view returns(uint){ //Individual account balance
        return depositorsPam[msg.sender].totalBalance;
    }

    function findUserPam(address _address, bytes32 _hashMoney) private{
        uint i; 
        for(i=0;i<depositorsPam[_address].hashMoneyList.length;i++){ 
            if(depositorsPam[_address].hashMoneyList[i] == _hashMoney){ 
                depositorsPam[_address].used = i; 
            } 
        }  
    } 

    function remove() public { //Remove Temporay data
        delete depositors[msg.sender].hashMoneyList;
        delete depositors[msg.sender].money;
    }

    function viewHashesAndValue ()public view returns(bytes32, uint256){
        return (depositors[msg.sender].hashMoneyList, depositors[msg.sender].money);

    }

    function viewAllHash3256 ()public view returns(bytes32 [] memory){
        return allhash3256;
    }

    function countHashes ()public view returns(uint){
        return allhash3256.length;
    }

    function viewContractBalance()public view returns(uint){
        return calculatedBalance;
    }
   
    function withdrawBalance () public { 
        require(!locked); //Reentrancy attack security
        locked = true; 
        if(depositorsPam[msg.sender].withdrawBalanceRequested == false){
            depositorsPam[msg.sender].time = block.timestamp;
            depositorsPam[msg.sender].withdrawBalanceRequested = true;
        }else {
            require(depositorsPam[msg.sender].withdrawBalanceRequested == true, "You need to wait");
            require(depositorsPam[msg.sender].time + 20 < block.timestamp, "the time is not enough");
            uint empty = depositorsPam[msg.sender].totalBalance; 
            depositorsPam[msg.sender].totalBalance = 0;   
            calculatedBalance -= empty;       
            msg.sender.transfer(empty);
            for(uint i=0;i<depositorsPam[msg.sender].hashMoneyList.length;i++){ 
                for(uint j = 0; j<allCountIndex.length; j++){

                    if(allCountIndex[j] == depositorsPam[msg.sender].countIndex[i]){ 
                        allCountIndex[j] = allCountIndex[allCountIndex.length-1]; 
                        allCountIndex.pop();
                        bytes32 tt = allhash3256[j];
                        emit withdrawalEvent(tt);
                        allhash3256[j] = allhash3256[allhash3256.length-1]; 
                        allhash3256.pop();
                        
                    } 
                }
            }
            delete depositorsPam[msg.sender].hashMoneyList;
            delete depositorsPam[msg.sender].money;
            delete depositorsPam[msg.sender].countIndex;
            depositorsPam[msg.sender].withdrawBalanceRequested = false;         
        }
        locked = false;
    }

    function withdrawDifference () public returns(uint){
        require(msg.sender == owner);
        uint tt = address(this).balance - calculatedBalance;
        owner.transfer(tt);
        return tt;
    }

    function encryptDecrypt(bytes32 source, bytes32 key) public pure returns(bytes32 result) {
        result = source ^ key;
    }

    // function decrypt(bytes32 encryptedMessage, bytes32 key) public pure returns(bytes32 message) {
    //     message = encryptedMessage ^ key;
    // }

    // function genKey(address _address) public pure returns (bytes32 key){
    //     key = keccak256(abi.encodePacked(_address));
    // }

    receive() external payable{}

}
