pragma solidity ^0.4.19;

import "./Owned.sol";

contract Pausable is Owned {
	event Pause();
	event Unpause();

	bool public paused = false;


	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	modifier whenPaused() {
		require(paused);
		_;
	}

	function pause() onlyOwner whenNotPaused public {
		paused = true;
		Pause();
	}

	function unpause() onlyOwner whenPaused public {
		paused = false;
		Unpause();
	}
}
