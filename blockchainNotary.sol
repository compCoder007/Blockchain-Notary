//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Main {


// ============================== SIGN UP AND LOGIN ==================================

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender==owner,"Not the Contract Owner");
        _;
    }

    enum State {
        Andhra_Pradesh,
        Arunachal_Pradesh,
        Assam,
        Bihar,
        Chhattisgarh,
        Goa,
        Gujarat,
        Haryana,
        Himachal_Pradesh,
        Jharkhand,
        Karnataka,
        Kerala,
        Madhya_Pradesh,
        Maharashtra,
        Manipur,
        Meghalaya,
        Mizoram,
        Nagaland,
        Odisha,
        Punjab,
        Rajasthan,
        Sikkim,
        Tamil_Nadu,
        Telangana,
        Tripura,
        Uttar_Pradesh,
        Uttarakhand,
        West_Bengal,
        Andaman_and_Nicobar_Islands,
        Chandigarh,
        Dadra_and_Nagar_Haveli_and_Daman_and_Diu,
        Delhi,
        Lakshadweep,
        Puducherry
    }

    struct User {
        string userName;
        State state;
        string aadhar;
        string pan;
    }

    struct Authority {
        string name;
        State state;
    }

    mapping (address => User) userDetails;
    mapping (address => Authority) authorityDetails;
    mapping (address => uint8) approvedUsers;
    mapping (address => uint8) approvedAuthorities;
    

    // IN THE ABOVE MAPPINGS, UINT VALUE DEFINES
    // 0 -> entry doesn't exist
    // 1 -> entry has sent a request
    // 2 -> entry has been approved
    // 3 -> entry has registered successfully
    
    address[] userRequests;
    
    address[] authorityRequests;

    function registerUser (string memory _userName, State _state, string memory _aadhar, string memory _pan) public {
        require(approvedUsers[msg.sender]==2,"not approved user");
        if(approvedUsers[msg.sender]==2) {
            User memory user;
            user.userName = _userName;
            user.state = _state;
            user.aadhar = _aadhar;
            user.pan = _pan;
            userDetails[msg.sender] = user;
            approvedUsers[msg.sender]=3;
        }
    }

    function sendUserRequest () public {
        if(approvedUsers[msg.sender]==0){
            approvedUsers[msg.sender]=1;
            userRequests.push(msg.sender);
        }
    }

    
    modifier onlyAuthority {
        require(approvedAuthorities[msg.sender]==2,"Not an Authority");
        _;
    }


    function approveRequest(address _requester) public onlyAuthority {
        require(approvedUsers[_requester]==1,"invalid operation");
        approvedUsers[_requester]=2; 
    }

    function approveAuthority(address _requester) public onlyOwner {
        require(approvedUsers[_requester]==1,"invalid operation");
        approvedAuthorities[_requester]=2;
    }

    function registerAuthority (string memory _name,State _state) public {
        require(approvedAuthorities[msg.sender]==2,"invalid operation");
        Authority memory authority;
        authority.name = _name;
        authority.state = _state;
        authorityDetails[msg.sender]=authority;
        approvedAuthorities[msg.sender]=3;
    }

    function sendAuthorityRequest () public {
        require(approvedAuthorities[msg.sender]==0,"invalid operation");
        approvedAuthorities[msg.sender]=1;
        authorityRequests.push(msg.sender);
    }

// -------------------------- GETTER METHODS -----------------------------------------

    function getUserType() public isActive view returns (uint8) {
        if (approvedUsers[msg.sender]==3) {
            return 1;
        }
        else if (approvedAuthorities[msg.sender]==3) {
            return 3;
        }
        else {
            return 0;
        }
    }

    function getUserDetails(address _addr) public isActive view returns (string[3] memory) {
        require(approvedUsers[_addr]==3,"Invalid User address");
        return [ userDetails[_addr].userName, userDetails[_addr].aadhar, userDetails[_addr].pan ];
    }

// -------------------------------------------------------------------------------

// --------------------------- SESSION HANDLING ----------------------------------

    mapping (address => bool) activeUsers;

    modifier isActive {
        require(activeUsers[msg.sender]==true || msg.sender==owner,"user logged out");
        _;
    }

    function signout() public isActive {
        activeUsers[msg.sender]=false;
    }

    function login() public {
        require(approvedAuthorities[msg.sender]==3 || approvedUsers[msg.sender]==3,"invalid address");
        activeUsers[msg.sender] = true;
    }



// =============================== END OF SECTION ===================================



// =============================== LAND ASSETS =======================================

    struct Land {
        string surveyNumber;
        address owner;
        uint areaInSquareMeters;
        string location;
        State state;
        bytes32 docHash;
        address[] previousOwners;
    }

    mapping(string => Land) landDetails;
    mapping(address => string[]) ownedLands;
    string[] lands;
    mapping (string => uint) approvedLands;
    mapping (address => string[]) transferRequests;

    modifier validUserAndLand(string memory _surveyNumber, address _reciever) {
        require(approvedLands[_surveyNumber]==3,"Invalid land");
        require(approvedUsers[_reciever]==3,"Invalid User");
        _;
    }

    function approveLand(string memory _surveyNumber,
        address _owner,
        uint _areaInSquareMeters,
        string memory _location,
        State _state,
        bytes32 _docHash) public isActive onlyAuthority {
            require(_state==authorityDetails[msg.sender].state,"Authority is not in same state as of land located");
            approvedLands[_surveyNumber] = 3;
            address[] memory a;

            Land memory land = Land(_surveyNumber,_owner,_areaInSquareMeters,_location,_state,_docHash,a);

            landDetails[_surveyNumber] = land;
            ownedLands[_owner].push(_surveyNumber);
            lands.push(_surveyNumber);
    }

    function requestTransferLand (string memory _surveyNumber, address _reciever) isActive public {
        require(landDetails[_surveyNumber].owner == msg.sender,"Requestor is not owner");
        transferRequests[_reciever].push(_surveyNumber);
    }

    function cancelTransferRequest (string memory _surveyNumber,address _reciever) isActive public validUserAndLand(_surveyNumber, _reciever) isActive {
        require(landDetails[_surveyNumber].owner == msg.sender,"Requestor is not owner");

        for (uint i = 0; i < transferRequests[_reciever].length; i++) {
            if (keccak256(bytes(transferRequests[_reciever][i])) == keccak256(bytes(_surveyNumber))) {
                // Move the last element into the position of the element to be removed
                transferRequests[_reciever][i] = transferRequests[_reciever][transferRequests[_reciever].length - 1];
                // Remove the last element
                transferRequests[_reciever].pop();
            }
        }
    }

    function acceptTransferRequest (string memory _surveyNumber) public validUserAndLand(_surveyNumber, msg.sender) isActive {
        
        for (uint i = 0; i < transferRequests[msg.sender].length; i++) {
            if (keccak256(bytes(transferRequests[msg.sender][i])) == keccak256(bytes(_surveyNumber))) {

                //Remove ownership of present owner
                address _owner = landDetails[_surveyNumber].owner;
                landDetails[_surveyNumber].previousOwners.push(_owner);
                for(uint j=0;i<ownedLands[_owner].length;j++){
                    if (keccak256(bytes(ownedLands[_owner][j])) == keccak256(bytes(_surveyNumber))) {
                        ownedLands[_owner][j] = ownedLands[_owner][ownedLands[_owner].length-1];
                        ownedLands[_owner].pop();
                    }
                }
                
                landDetails[_surveyNumber].owner = msg.sender;
                ownedLands[msg.sender].push(_surveyNumber);


                // Move the last element into the position of the element to be removed
                transferRequests[msg.sender][i] = transferRequests[msg.sender][transferRequests[msg.sender].length - 1];
                // Remove the last element
                transferRequests[msg.sender].pop();

            }
        }   
    }

    function rejectTransferRequest (string memory _surveyNumber) isActive public validUserAndLand(_surveyNumber, msg.sender) isActive {

        for (uint i = 0; i < transferRequests[msg.sender].length; i++) {
            if (keccak256(bytes(transferRequests[msg.sender][i])) == keccak256(bytes(_surveyNumber))) {
                // Move the last element into the position of the element to be removed
                transferRequests[msg.sender][i] = transferRequests[msg.sender][transferRequests[msg.sender].length - 1];
                // Remove the last element
                transferRequests[msg.sender].pop();
            }
        }
    }


//----------------------------- GETTER METHODS -----------------------------------

    function getLandDetails (string memory _surveyNumber) public isActive validUserAndLand(_surveyNumber,msg.sender) view returns (Land memory) {
        return landDetails[_surveyNumber];
    }

    function getLandTransferRequestsList() public isActive view returns (string [] memory) {
        require(approvedUsers[msg.sender]==3,"invalid user");
        return transferRequests[msg.sender];
    }

    function getOwnedLands() public isActive view returns (string[] memory) {
        return ownedLands[msg.sender];
    }


//=========================== END OF SECTION ==========================================


// ===============================CONTRACTS ===========================================

    enum ContractStatus { Pending, Active, cancelledRequest, Cancelled, Rejected }
    uint256 contractId = 1;

    struct Contract {
        uint id;
        address party1;
        address party2;
        uint256 startDate;
        uint256 endDate;
        string description;
        ContractStatus status;
    }

    mapping (uint256 => Contract) contractDetails;
    mapping (address => uint256[]) contractRequests;
    mapping (address => uint256[]) ownedContracts;


    function requestContract(address _party2, string memory _description,uint _startDate,uint _endDate) public {
        Contract memory c = Contract(contractId,msg.sender,_party2,_startDate,_endDate,_description,ContractStatus.Pending);
        contractDetails[contractId] = c;
        contractRequests[_party2].push(contractId);
        ownedContracts[msg.sender].push(contractId);
        contractId+=1;
    }

    function cancelContractRequest(uint256 _id) public isActive {
        require(contractDetails[_id].party1 == msg.sender,"Requestor is not owner");
        contractDetails[_id].status = ContractStatus.cancelledRequest;
    }

    function acceptContract(uint256 _id) public isActive {
        require(contractDetails[_id].party2 == msg.sender,"Acceptor is not a part of contract");
        contractDetails[_id].status = ContractStatus.Active;
        ownedContracts[msg.sender].push(_id);
    }

    function rejectContract(uint256 _id) public isActive {
        require(contractDetails[_id].party2 == msg.sender,"Acceptor is not a part of contract");
        contractDetails[_id].status = ContractStatus.Rejected;
    }

// --------------------------- GETTER METHODS -------------------------------------------

    function getContractDetails (uint256 _id) public isActive view returns(Contract memory) {
        require(_id < contractId, "Invalid contract Id");
        return contractDetails[_id];
    }

    function getContractRequests() public isActive view returns(uint256[] memory) {
        return contractRequests[msg.sender];
    }

    function getOwnedContracts() public isActive view returns (uint[] memory){
        return ownedContracts[msg.sender];
    }

//============================ END OF SECTION ===========================================


}