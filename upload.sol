// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentHashStorage {
    address public owner;
    mapping(address => bool) public authorizedUsers;
    mapping(bytes32 => bool) public uploadedHashes;

    event HashUploaded(address indexed uploader, bytes32 indexed documentHash);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedUsers[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedUsers[msg.sender] = true;
    }

    function addAuthorizedUser(address _user) external onlyOwner {
        authorizedUsers[_user] = true;
    }

    function removeAuthorizedUser(address _user) external onlyOwner {
        authorizedUsers[_user] = false;
    }

    function uploadHash(bytes32 _documentHash) external onlyAuthorized {
        require(!uploadedHashes[_documentHash], "Hash already uploaded");
        uploadedHashes[_documentHash] = true;
        emit HashUploaded(msg.sender, _documentHash);
    }
}
