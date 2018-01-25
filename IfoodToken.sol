pragma solidity ^0.4.19;

import "./SafeMath.sol";
import "./StandardToken.sol";
import "./Pausable.sol";

contract IfoodToken is StandardToken, Pausable {
    using SafeMath for uint;
    
    string public name = "Ifood Token";
    string public symbol = "IFO";
    uint8 public decimals = 18;


	uint public startBlock = 0;
    uint public endBlock = 0;
	uint public price = 0;
    uint public foundationLockup = 4505142;//locked for this many blocks after endBlock (assuming 14 second blocks, this is 2 years)
    uint public developerLockup = 1110857; //locked for this many blocks after endBlock (assuming 14 second blocks, this is 6 months)

	address public foundation = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;//TODO
	address public developer = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;//TODO

    uint foundationAllocation  = 30 * 10**uint(decimals-2); // 30% of totalSupply to foundation.
	uint ecosystemAllocation   = 10 * 10**uint(decimals-2); // 10% of totalSupply to ecosystem.
	uint developerAllocation   = 15 * 10**uint(decimals-2); // 15% of totalSupply to developer.
    uint distributedAllocation = 45 * 10**uint(decimals-2); // 45% of totalSupply to crowd.
    uint public distributedTokensCap = 0; 

    mapping (address => mapping (uint8 => uint)) public freezeOf;

	event Burn(address indexed owner, uint value);
    event Unfreeze(address indexed from, uint256 value);
	event Receive(address indexed from, uint value);
    event Withdraw(address indexed sender, uint eth);

    function IfoodToken(uint _price, uint _totalSupply, uint _startBlock, uint _endBlock) public {
		startBlock = _startBlock;
		endBlock = _endBlock;
		price = _price;
		totalSupply = _totalSupply * 10**uint(decimals);
		balances[foundation]    = totalSupply.mul(ecosystemAllocation).div(10**uint(decimals));
		freezeOf[foundation][0] = totalSupply.mul(foundationAllocation).div(10**uint(decimals));
		distributedTokensCap    = totalSupply.mul(distributedAllocation).div(10**uint(decimals));
		uint developerSubToken  = totalSupply.mul(developerAllocation).div(4 * 10 **uint(decimals));
		freezeOf[developer][0]= developerSubToken;
		freezeOf[developer][1]= developerSubToken;
		freezeOf[developer][2]= developerSubToken;
		freezeOf[developer][3]= developerSubToken;
    }
    
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
		if (block.number <= endBlock) revert();
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {
		if (block.number <= endBlock) revert();
        return super.transferFrom(_from, _to, _value);
    }

	function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
		if (block.number <= endBlock) revert();
		return super.approve(_spender, _value);
	}

	function buy() public whenNotPaused payable {
		require(block.number >= startBlock && block.number <= endBlock && msg.value > 0);
		uint token = msg.value.mul(price);
		distributedTokensCap = distributedTokensCap.sub(token);
		require(distributedTokensCap >= 0);
		balances[msg.sender] = balances[msg.sender].add(token);
		owner.transfer(msg.value); //TODO to whom
		Receive(msg.sender, msg.value);
	}

	function burn(uint value) public whenNotPaused returns (bool success) {
		require(value > 0 && balances[msg.sender] >= value);
		balances[msg.sender] = balances[msg.sender].sub(value);
		totalSupply = totalSupply.sub(value);
		Burn(msg.sender, value);
		return true;
	}

	function unfreeze() public whenNotPaused returns (bool success) {
		require(msg.sender == foundation || msg.sender == developer);

		bool ret = false;

		if (msg.sender == foundation && block.number > (endBlock + foundationLockup) && freezeOf[msg.sender][0] > 0) {
			uint unfreezeToken = freezeOf[msg.sender][0];
			balances[msg.sender] = balances[msg.sender].add(unfreezeToken);
			freezeOf[msg.sender][0] = 0;
			Unfreeze(msg.sender, unfreezeToken);
			ret = true;
		} 
		if (msg.sender == developer) {
			if (block.number > (endBlock + 0 * developerLockup) && freezeOf[msg.sender][0] > 0) {
				uint unfreezeToken1 = freezeOf[msg.sender][0];
				balances[msg.sender] = balances[msg.sender].add(unfreezeToken1);
				freezeOf[msg.sender][0] = 0;
				Unfreeze(msg.sender, unfreezeToken);
				ret = true;
			}
			if (block.number > (endBlock + 1 * developerLockup) && freezeOf[msg.sender][1] > 0) {
				uint unfreezeToken2 = freezeOf[msg.sender][1];
				balances[msg.sender] = balances[msg.sender].add(unfreezeToken2);
				freezeOf[msg.sender][1] = 0;
				Unfreeze(msg.sender, unfreezeToken);
				ret = true;
			}
			if (block.number > (endBlock + 2 * developerLockup) && freezeOf[msg.sender][2] > 0) {
				uint unfreezeToken3 = freezeOf[msg.sender][2];
				balances[msg.sender] = balances[msg.sender].add(unfreezeToken3);
				freezeOf[msg.sender][2] = 0;
				Unfreeze(msg.sender, unfreezeToken);
				ret = true;
			}
			if (block.number > (endBlock + 3 * developerLockup) && freezeOf[msg.sender][3] > 0) {
				uint unfreezeToken4 = freezeOf[msg.sender][3];
				balances[msg.sender] = balances[msg.sender].add(unfreezeToken4);
				freezeOf[msg.sender][3] = 0;
				Unfreeze(msg.sender, unfreezeToken);
				ret = true;
			}
		}

		return ret;
    }

	
	function withdrawEther(uint amount) public onlyOwner {
		require(amount > 0);
		owner.transfer(amount);//TODO to whom
		Withdraw(owner, amount);
	}
	
	function () public payable {
         revert();
	}
}
