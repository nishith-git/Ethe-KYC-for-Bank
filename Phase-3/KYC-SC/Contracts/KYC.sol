pragma solidity ^0.5.9;

contract KYC{


    address admin;
    uint256 minRating;

    struct Customer {
        string userName;   
        string data;
        bool kycStatus;
        uint256 downVotes;
        uint256 upVotes;
        address bank;
    }
    
    struct Bank {
        string name;
        address ethAddress;
        uint256 complaintsReported;
        uint256 KYC_count;
        bool isAllowedToVote;
        string regNumber;
    }
    
    struct KYC_request{
        
        string Username;
        address bankAddress;
        string customerData;
    }
    
    constructor() public{
        admin = msg.sender;
        minRating = (100 / 2);
    }
    
    mapping(string => Customer) customers;

    mapping(address => Bank) banks;
    
    mapping(string => KYC_request) kyc_request;
    
    
    
    
        // Checks whether the requestor is admin
    modifier isAdmin {
        require(admin == msg.sender,"Only admin is allowed to operate this functionality");
        _;
    }


    // Checks whether bank has been validated and added by admin
    modifier isBankValid {
        require(banks[msg.sender].ethAddress == msg.sender, "Unauthenticated requestor! Bank not been added by admin.");
        _;
    }

    
        function addRequest(string memory _Username, string memory _customerData) public isBankValid returns(uint8){
        require(kyc_request[_customerData].bankAddress == address(0), "Customer is already present, please call modifyCustomer to edit the customer data");
        
        kyc_request[_customerData].customerData = _customerData;
        kyc_request[_customerData].Username = _Username;
        kyc_request[_customerData].bankAddress = msg.sender;
        
        banks[msg.sender].KYC_count +=1;
        return 1;
    }
    
    function removeRequest(string memory _Username, string memory _customerData) public isBankValid returns (uint8) {
        
        require(equalStr(kyc_request[_customerData].Username, _Username), "KYC request doesn't exist for this customer");
        delete kyc_request[_customerData];
        
       
        return 1;
    }
    
    function addCustomer(string memory _userName, string memory _customerData) public isBankValid returns (uint8) {
        
        require(customers[_userName].bank == address(0), "Customer is already present, please call modifyCustomer to edit the customer data");
        
        customers[_userName].data = _customerData;
        customers[_userName].userName = _userName;
        customers[_userName].bank = msg.sender;
        
        return 1;
    }
    
    function viewCustomer(string memory _userName) public view returns (string memory, string memory, address) {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        return (customers[_userName].userName, customers[_userName].data, customers[_userName].bank);
    }
    
    function viewBankDetails (address _bankAddress) public view returns (string memory, string memory, uint256, address, uint256, bool) {
        require(banks[_bankAddress].ethAddress == _bankAddress, "Bank is not present in the database");
        return (banks[_bankAddress].name, banks[_bankAddress].regNumber,banks[_bankAddress].KYC_count, banks[_bankAddress].ethAddress, banks[_bankAddress].complaintsReported, banks[_bankAddress].isAllowedToVote);
    }
    
    function reportBank (address _bankAddress) public isBankValid returns (uint8){
        
        require(banks[_bankAddress].ethAddress == _bankAddress, "This bank doesn't exist");
        require(msg.sender != _bankAddress, "Bank can not report their own bank");
        
        if(banks[_bankAddress].KYC_count > minRating){
            banks[_bankAddress].isAllowedToVote = true;
        }
    }
    
    function modifyCustomer(string memory _userName, string memory _newcustomerData) public isBankValid returns (uint8) {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        customers[_userName].data = _newcustomerData;
        return 1;
    }    
    
    function getBankComplains (address _bankAddress) public view isBankValid returns (uint256){
        require(banks[_bankAddress].ethAddress == _bankAddress, "No complain registerd");
        
        return (banks[_bankAddress].complaintsReported);
    }
   
    
    function upVoteCustomer (string memory _customerName) public isBankValid returns (uint8){
        //require (customers[_customerName].userName == _customerName, "This customer doesn't exist");
        require(banks[msg.sender].ethAddress == msg.sender, "Unauthenticated requestor");
        customers[_customerName].upVotes +=1;
       return 1;
    }
    
    function downVoteCustomer (string memory _customerName) public isBankValid returns (uint8){
       // require (customers[_customerName].userName == _customerName, "This customer doesn't exist");
        require(banks[msg.sender].ethAddress == msg.sender, "Unauthenticated requestor");
        customers[_customerName].upVotes -=1;
       return 1;
    }
    
    function addBank (string memory _bankName, address _bankAddress, string memory _regNumber) public isAdmin returns (bool){
       
        
        require(banks[_bankAddress].ethAddress != _bankAddress, "Bank with same address already exists");
        
        banks[_bankAddress].name = _bankName;
        banks[_bankAddress].ethAddress =_bankAddress;
        banks[_bankAddress].complaintsReported =0;
        banks[_bankAddress].isAllowedToVote = true;
        banks[_bankAddress].regNumber =_regNumber;
        
        return true;
        
    }
    
    function removeBank (address _bankAddress) public isAdmin returns (bool){
        require(banks[_bankAddress].ethAddress == _bankAddress, "Bank doesn't exist");
        
        delete banks[_bankAddress];
        return true;
    }
    
     function modifyBankisAllowedToVote(address _bankAddress, bool _isAllowed) public isAdmin returns (bool) {
        require(banks[_bankAddress].ethAddress != address(0), "Bank is not present in the database");
        banks[_bankAddress].isAllowedToVote = _isAllowed;
        
        return true;
    }
    
    function equalStr(string storage _x, string memory _y) internal view returns (bool) {
        bytes storage a = bytes(_x);
        bytes memory b = bytes(_y); 
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
                return false;
        }
        return true;
    }
    
}    


