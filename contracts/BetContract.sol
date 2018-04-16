pragma solidity ^0.4.18;

contract BetContract {

	struct Result {
	    uint time; //开奖时间，管理客户端传递的时间
	    uint result; //开奖结果，1~6
	    uint odds; //赢一方的最终赔率，单位%
	}

	event LOG_NewBet(address playerAddress, uint amount);

	uint private prevBlockNum; //开始时间
	bool private isStopped; //合约是否已停止
	bool private canBet; //是否可以投注
	uint public profit;//盈利
	address private owner; //创建者的地址
	
	address[] private addressBig; //所有压大的地址
	address[] private addressSmall; //所有压小的地址
	mapping(address => uint) private bigMap; //压大的map
	mapping(address => uint) private smallMap; //压小的map
	Result private lastResult; //开奖历史，只保留最近的1条
	
	modifier onlyIfNotStopped {
        require(!isStopped);
        _;
    }
	
	modifier onlyCanBet {
		require(canBet);
		canBet = false;
        _;
		canBet = true;
	}
	
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
    function BetContract() public {
		prevBlockNum = block.number;
		isStopped = false;
		canBet = true;
		profit = 0;
		owner = 0xEd5b17af63C775B2f1101af5AB064547B5E32C44;
    }
	
	function() public payable {
        bet(msg.data.length > 0);
    }
	
	function bet(bool v) public payable {
		require(canBet);
		require(msg.value >= 10 finney);
		address add = msg.sender;
		uint value = msg.value;
		if (v) {
			bigMap[add] += value;
			addAddress(add, addressBig);
		} else {
			smallMap[add] += value;
			addAddress(add, addressSmall);
		}
		LOG_NewBet(add, value);
	}
	
	function addAddress(address a, address[] storage addressArray) internal {
		for (uint i = 0; i < addressArray.length; i ++ ) {
			if (addressArray[i] == a) {
				return;
			}
		}
		addressArray.push(a);
	}
	
	function myBet() public view returns (uint, uint) {
		return (bigMap[msg.sender], smallMap[msg.sender]);
	}
	
	//开奖
	function result(uint seed) public payable onlyIfNotStopped onlyCanBet onlyOwner {
		//1.查看是否满足开奖条件：a、合约未停止isStopped为false b、canBet为true c、双边都有人投注
		require(addressBig.length > 0 && addressSmall.length > 0 );
		//2.设置canBet为false
		//3.开奖：a、获取随机数，大于等于3则为大，小于3为小 b、统计奖池总金额、获胜方总金额 c、按比例派发奖金
		uint r = randomGen(seed);
		bool big = r >= 3;
		uint all = 0;//奖池总金额
		uint winAll = 0;//获胜方总金额
		for (uint i = 0; i < addressBig.length; i ++) {
			uint b = bigMap[addressBig[i]];
			all += b;
			if (big) {
				winAll += b;
			}
		}
		for (i = 0; i < addressSmall.length; i ++) {
			b = smallMap[addressSmall[i]];
			all += b;
			if (!big) {
				winAll += b;
			}
		}
		all = 99 * all / 100;
		profit = all / 99;
        lastResult = Result(seed, r + 1, all*100/winAll);
		//c、按比例派发奖金
		for (i = 0; i < addressBig.length; i ++) {
			address k = addressBig[i];
			b = bigMap[k];
			uint jj =  all * b / winAll;
			delete bigMap[k];
			if (big) {
				require (k.send(jj));
			}
		}

		for (i = 0; i < addressSmall.length; i ++) {
			k = addressSmall[i];
			b = smallMap[k];
			jj = all * b / winAll;
			delete smallMap[k];
			if (!big) {
				require (k.send(jj));
			}
		}

		delete addressBig;
		delete addressSmall;
		
		//4.canBet设置为true
	}
	
	function countBet() public view returns(uint, uint) {
		return (addressBig.length, addressSmall.length);
	}
	
	//提现
	function getMoney() public payable onlyOwner {
		owner.transfer(profit);
	}
	
	function randomGen(uint seed) internal view returns (uint){
		uint r = uint(keccak256(block.blockhash(block.number-1), seed ))%6;
		return r;
    }

    function allBet() public view returns (uint, uint) {
        uint bigAll = 0;
        for (uint i = 0; i < addressBig.length; i ++) {
            bigAll += bigMap[addressBig[i]];
        }
        uint smallAll = 0;
        for (i = 0; i < addressSmall.length; i ++) {
            smallAll += smallMap[addressSmall[i]];
        }
        return (bigAll, smallAll);
    }

    function getLastResult() public view returns (uint, uint, uint) {
        return (lastResult.time,  lastResult.result,  lastResult.odds);
    }
}