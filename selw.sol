pragma solidity ^0.8.0;

contract LastWill {
    address payable private owner;
    address payable private beneficiary;
    uint private deathDate;
    bool private deceased;

    mapping(address => uint) private balances;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event NewOwner(address indexed _newOwner);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAfterDeath {
        require(deceased == true);
        _;
    }

    constructor(address payable _beneficiary, uint _deathDate) public {
        owner = msg.sender;
        beneficiary = _beneficiary;
        deathDate = _deathDate;
        deceased = false;
    }

    function transfer(address payable _to, uint _amount) public onlyOwner returns(bool success) {
        require(_amount <= balances[owner]);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        emit Transfer(owner, _to, _amount);
        return true;
    }

    function distribute() public onlyAfterDeath returns(bool success) {
        require(msg.sender == beneficiary);
        require(address(this).balance > 0);
        uint amount = address(this).balance;
        beneficiary.transfer(amount);
        emit Transfer(owner, beneficiary, amount);
        return true;
    }

    function isDeceased() public onlyOwner returns(bool) {
        if (deathDate <= block.timestamp) {
            deceased = true;
            distribute();
        }
        return deceased;
    }

    function changeOwner(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit NewOwner(_newOwner);
    }

    receive() external payable {
        require(deceased == false);
        balances[owner] += msg.value;
    }
}
