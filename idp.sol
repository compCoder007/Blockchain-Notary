//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Main {


// ============================== SIGN UP AND LOGIN ==================================

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender==owner,"Only owner is allowed to perform this operation");
        _;
    }

    enum UserType {Owner, User, Inspector, Authority}

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
    mapping (address => uint8) approvedInspectors;

    // IN THE ABOVE MAPPINGS, UINT VALUE DEFINES
    // 0 -> entry doesn't exist
    // 1 -> entry has sent a request
    // 2 -> entry has been approved
    // 3 -> entry has registered successfully
    
    address[] userRequests;
    address[] inspectorRequests;
    address[] authorityRequests;

    function registerUser (string memory _userName, State _state, string memory _aadhar, string memory _pan) public returns(bool) {
        require(approvedUsers[msg.sender]!=3,"already registered");
        if(approvedUsers[msg.sender]==2) {
            User memory user;
            user.userName = _userName;
            user.state = _state;
            user.aadhar = _aadhar;
            user.pan = _pan;
            userDetails[msg.sender] = user;
            approvedUsers[msg.sender]=3;
            return true;
        }
        else{
            return false;
        }
    }

    function sendUserRequest () public returns(bool){
        require(approvedUsers[msg.sender]!=3,"already registered");
        if(approvedUsers[msg.sender]==0){
            approvedUsers[msg.sender]=1;
            userRequests.push(msg.sender);
            return true;
        }
        else if (approvedUsers[msg.sender]==1){
            return true;
        }
        else{
            return false;
        }
    }

    function registerInspector (string memory _userName, State _state, string memory _aadhar, string memory _pan) public returns(bool) {
        require(approvedInspectors[msg.sender]!=3,"already registered");
        if(approvedInspectors[msg.sender]==2) {
            User memory user;
            user.userName = _userName;
            user.state = _state;
            user.aadhar = _aadhar;
            user.pan = _pan;
            userDetails[msg.sender] = user;
            return true;
        }
        else{
            return false;
        }
    }

    function sendInspectorRequest () public returns(bool){
        require(approvedInspectors[msg.sender]!=3,"already registered");
        if(approvedInspectors[msg.sender]==0){
            approvedInspectors[msg.sender]=1;
            inspectorRequests.push(msg.sender);
            return true;
        }
        else if (approvedInspectors[msg.sender]==1){
            return true;
        }
        else{
            return false;
        }
    }

    modifier onlyAuthority {
        require(approvedAuthorities[msg.sender]==2,"Only approved authorities can perform this operation");
        _;
    }


    function approveRequest(address _requester) public onlyAuthority returns(bool) {
        if(approvedUsers[_requester]==1){
            approvedUsers[_requester]=2;
            return true;
        }
        else if(approvedInspectors[_requester]==1){
            approvedInspectors[_requester]=2;
            return true;
        }
        else{
            return false;
        }
    }

    function approveAuthority(address _requester) public onlyOwner returns(bool) {
        if(approvedAuthorities[_requester]==1){
            approvedAuthorities[_requester]=2;
            return true;
        }
        else{
            return false;
        }
    }

    function registerAuthority (string memory _name,State _state) public returns(bool) {
        if(approvedAuthorities[msg.sender]==2){
            Authority memory authority;
            authority.name = _name;
            authority.state = _state;
            authorityDetails[msg.sender]=authority;
            approvedAuthorities[msg.sender]=3;
            return true;
        }
        else{
            return false;
        }
    }

    function sendAuthorityRequest () public returns(bool){
        require(approvedAuthorities[msg.sender]!=3,"already registered");
        if(approvedAuthorities[msg.sender]==0){
            approvedAuthorities[msg.sender]=1;
            authorityRequests.push(msg.sender);
            return true;
        }
        else if (approvedAuthorities[msg.sender]==1){
            return true;
        }
        else{
            return false;
        }
    }

// -------------------------- GETTER METHODS -----------------------------------------

    function getUserType() public isActive view returns (uint8) {
        if (approvedUsers[msg.sender]==3) {
            return 1;
        }
        else if (approvedInspectors[msg.sender]==3) {
            return 2;
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

    function signout() public isActive returns(bool){
        activeUsers[msg.sender]=false;
        return true;
    }

    function login() public returns(bool){
        if(approvedAuthorities[msg.sender]==3 || approvedInspectors[msg.sender]==3 || approvedUsers[msg.sender]==3){
            activeUsers[msg.sender] = true;
            return true;
        }
        else {
            return false;
        }
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
    }

    mapping(string => Land) landDetails;
    mapping(address => string[]) ownedLands;
    string[] lands;
    mapping (string => uint) approvedLands;
    mapping (address => string[]) transferRequests;

    function approveLand(string memory _surveyNumber,
        address _owner,
        uint _areaInSquareMeters,
        string memory _location,
        State _state,
        bytes32 _docHash) public isActive onlyAuthority returns(bool) {
            if(_state!=authorityDetails[msg.sender].state){
                return false;
            }
            approvedLands[_surveyNumber] = 3;
            Land memory land;
            land.surveyNumber = _surveyNumber;
            land.owner = _owner;
            land.areaInSquareMeters = _areaInSquareMeters;
            land.location = _location;
            land.state = _state;
            land.docHash = _docHash;
            landDetails[_surveyNumber] = land;
            ownedLands[_owner].push(_surveyNumber);
            lands.push(_surveyNumber);
            return true;
    }

    function requestTransferLand (string memory _surveyNumber, address _reciever) isActive public returns(bool) {
        require(approvedLands[_surveyNumber]==3,"Invalid land");
        require(approvedUsers[_reciever]==3,"Invalid User");
        if(landDetails[_surveyNumber].owner != msg.sender){
            return false;
        }
        transferRequests[_reciever].push(_surveyNumber);
        return true;

    }

    function cancelTransferRequest (string memory _surveyNumber,address _reciever) isActive public isActive returns(bool) {
        require(approvedLands[_surveyNumber]==3,"Invalid land");
        require(approvedUsers[_reciever]==3,"Invalid User");
        if(landDetails[_surveyNumber].owner != msg.sender){
            return false;
        }
        for (uint i = 0; i < transferRequests[_reciever].length; i++) {
            if (keccak256(bytes(transferRequests[_reciever][i])) == keccak256(bytes(_surveyNumber))) {
                // Move the last element into the position of the element to be removed
                transferRequests[_reciever][i] = transferRequests[_reciever][transferRequests[_reciever].length - 1];
                // Remove the last element
                transferRequests[_reciever].pop();
                return true;
            }
        }
        return false;
    }

    function acceptTransferRequest (string memory _surveyNumber) public isActive returns (bool) {
        require(approvedLands[_surveyNumber]==3,"Invalid land");
        for (uint i = 0; i < transferRequests[msg.sender].length; i++) {
            if (keccak256(bytes(transferRequests[msg.sender][i])) == keccak256(bytes(_surveyNumber))) {

                //Remove ownership of present owner
                address _owner = landDetails[_surveyNumber].owner;
                for(uint j=0;i<ownedLands[_owner].length;j++){
                    if (keccak256(bytes(ownedLands[_owner][j])) == keccak256(bytes(_surveyNumber))) {
                        ownedLands[_owner][j] = ownedLands[_owner][ownedLands[_owner].length-1];
                    }
                }
                
                landDetails[_surveyNumber].owner = msg.sender;
                // Move the last element into the position of the element to be removed
                transferRequests[msg.sender][i] = transferRequests[msg.sender][transferRequests[msg.sender].length - 1];
                // Remove the last element
                transferRequests[msg.sender].pop();
                return true;
            }
        }
        return false;   
    }


    //----------------------------- GETTER METHODS -----------------------------------




}