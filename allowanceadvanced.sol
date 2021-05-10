// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// This contract allows an owner
// to send allowance to an address and authorize 
// the address to withdraw funds send to it.

// NOTE : This contract has an exception for the fallback function.
// You will need to work on removing the warning. To solve this problem
// You might need to add a receive ether function.

// library SafeMath
library SafeMath {
    
    // Function returning substraction
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        return a - b;
    }
    
    // Function returning addition
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        return a + b;
    }
    
}

// Reusable owner (Ownable) contract
contract Ownable {
    
    // Address bariable ~ owner
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
}

// Reusable allowance (Allowance) Contract 
contract Allowance is Ownable {
    
    // Using SafeMath contract
    using SafeMath for uint;
    
    // event 
    event AllowanceChanged(address indexed _forWho, address indexed _fromWho, uint _oldAmount, uint _newAmount);
    
    // Mapping variable ~ allowanceMoney
    mapping(address => uint) public allowanceMoney;

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
        // allowanceMoney[msg.sender] += msg.value; // old code
        
        // Reduce allowance user ~ add ~ from ~ SafeMath
        allowanceMoney[msg.sender] = allowanceMoney[msg.sender].add(msg.value)); // new code
    }
    
    // Function adding address to the allowance
    function addAllowance(address _who, uint _amount) public onlyOwner {
        
        // (emit) for (event)
        // (address indexed _forWho, ..., ..., ...) for (_who, ..., ..., ...)
        // (..., address indexed _fromWho, ..., ...) for (..., msg.sender, ..., ...)
        // (..., ..., uint _oldAmount, ...) for (..., ..., allowanceMoney[_who], ...)
        // (..., ..., ..., uint _newAmount) for (..., ..., ..., _amount)
        
        emit AllowanceChanged(_who, msg.sender, allowanceMoney[_who], _amount);
        
        // Assign the allowance to the address
        allowanceMoney[_who] = _amount;
    }
    
    // Function reduce allowance is not public, we cannot see  the remaining amount
    function reduceAllowance(address _who, uint _amount) internal {
        
        // (emit) for (event)
        // (address indexed _forWho, ..., ..., ...) for (_who, ..., ..., ...)
        // (..., address indexed _fromWho, ..., ...) for (..., msg.sender, ..., ...)
        // (..., ..., uint _oldAmount, ...) for (..., ..., allowanceMoney[_who], ...)
        // (..., ..., ..., uint _newAmount) for (..., ..., ..., _amount)
        emit AllowanceChanged(_who, msg.sender, allowanceMoney[_who], allowanceMoney[_who].sub(_amount));
        
        // Reduce allowance user ~ sub ~ from ~ SafeMath
        allowanceMoney[_who] = allowanceMoney[_who].sub(_amount);
    }
    
}

// Main contract (wallet)
contract Wallet is Allowance {
    
    // events
    event moneySent(address indexed _to, uint _amount);
    event moneyReceived(address indexed _from, uint _amount);
    
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
        
        // (emit) for (event)
        // (_to, ...) for (address indexed _to, ...)
        // (..., _amount) for (..., uint _amount)
        emit moneySent(_to, _amount);
        
        // Transger funds
        _to.transfer(_amount);
    }
    
    // When declaring ~ fallback ~ function also declare ~ receive ~ function
    // fallback still not working! 
    fallback () external payable {
        
        // (emit) for (event)
        // (msg.sender, ...) for (address indexed _from, ...)
        // (..., msg.value) for (..., uint _amount)
        emit moneyReceived(msg.sender, msg.value);
    }
    
    // When declaring fallback function also declare receive function
    // Include variables from ~ fallback ~ function
    receive() external payable { 
        
        // (emit) for (event)
        // (msg.sender, ...) for (address indexed _from, ...)
        // (..., msg.value) for (..., uint _amount)
        emit moneyReceived(msg.sender, msg.value);
        
    }
    
}
