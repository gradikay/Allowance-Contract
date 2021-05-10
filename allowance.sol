// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// This contract allows an owner
// to send allowance to an address and authorize 
// the address to withdraw funds send to it.

// NOTE : This contract has an exception for the fallback function.
// You will need to work on removing the warning. To solve this problem
// You might need to add a receive ether function.

contract Allowance {
    
    // Mapping variable ~ allowanceMoney
    mapping(address => uint) public allowanceMoney;
    
    // Address variable ~ owner
    address public owner;
    
    // Assigning values to variables
    constructor() {
        
        // Creator of the contract
        owner = msg.sender;
    }
    
    // Return a bool if the sender is the owner
    function isOnwer() public view returns(bool){
        
        // Retunr ture if msg.sender is the owner; else false
        return msg.sender == owner;
    }
    
    // Modifier for the contract owner
    modifier onlyOwner() {
        
        // if statment : Checking that it is the owner.
        require(msg.sender == owner, "Sorry: You are not the owner!");
        
        // Return the rest of the function
        _;
    }
    
    // Modifier for the contract owner and allowed user
    modifier ownerOrAllowed(uint _amount) {
        
        // if statment : Checking that it is the owner 
        // or that the amount is not greater the total allowance.
        require(isOnwer() || allowanceMoney[msg.sender] >= _amount, "Sorry: You are not allowed!");
        
        // Return the rest of the function
        _;
    }
    
    // Function depositing allowance money
    function depositFunds() public payable onlyOwner {
        
        // Display the amount deposited
        allowanceMoney[msg.sender] += msg.value;
    }
    
    // Function adding address to the allowance
    function addAllowance(address _who, uint _amount) public onlyOwner {
        
        // Assign the allowance to the address
        allowanceMoney[_who] = _amount;
    }
    
    function reduceAllowance(address _who, uint _amount) internal {
        
        // Reduce allowance
        allowanceMoney[_who] -= _amount;
    }
    
    // Function withdrawing the allowance money
    function withdrawFunds(address payable _to, uint _amount) public payable ownerOrAllowed(_amount) {
        
        // if statment : Checking that the amount is less than the total funds
        require(_amount <= address(this).balance, "Sorry: Not enough funds to withdraw!");
        
        // if statment : Checking that it is not the owner 
        // but the allowed user; reduce allowance.
        if(!isOnwer()){
            
            // 
            reduceAllowance(msg.sender, _amount);
        }
        
        // Transger funds
        _to.transfer(_amount);
    }
    
    fallback () external payable {
        
    }
}
