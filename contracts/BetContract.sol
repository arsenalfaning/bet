pragma solidity ^0.4.18;

contract BetContract {
	
	event LOG_NewBet(address playerAddress, uint amount);

	uint private prevBlockNum; //开始时间
    uint private seed;
	uint private r;
	bool private isStopped; //合约是否已停止
	bool private canBet; //是否可以投注
	
	
	mapping(address => uint) private bigMap; //压大的map
	mapping(address => uint) private smallMap; //压小的map
	
	modifier onlyIfNotStopped {
        require(!isStopped);
        _;
    }
	
	modifier validBet {
        require(msg.value >= 10 finney);
        _;
    }

    function BetContract() {
		prevBlockNum = block.number;
		seed = 50;
		r = 50;
		isStopped = false;
		canBet = true;
    }
	
	function() payable {
        bet(msg.data.length > 0);
    }
	
	function bet(bool v) payable {
		require(canBet);
		if (v) {
			bigMap[msg.sender] += msg.value;
		} else {
			smallMap[msg.sender] += msg.value;
		}
		LOG_NewBet(msg.sender, msg.value);
	}
	
	function myBet() public view returns (uint, uint) {
		return (bigMap[msg.sender], smallMap[msg.sender]);
	}
	
	function randomGen() internal{
		r = uint(sha3(block.blockhash(block.number-1), seed ))%100;
		seed = seed + 1;
    }
}