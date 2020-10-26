pragma solidity >=0.5.0 <0.7.0;

import './ERC20.sol';
import "./SafeMath.sol";
import './ERC20Detailed.sol';
import "./Address.sol";
import "./ReentrancyGuard.sol";

interface TokenRecipient {
  // must return true
    function tokensReceived(
        address from,
        uint amount,
        bytes calldata exData
    ) external returns (bool);
}

contract GoodCoin is ERC20 , ERC20Detailed("Good Coin", "GoodCoin", 6), ReentrancyGuard {
//contract GoodCoin is ERC20 , ERC20Detailed("Test Good Coin", "TestGoodCoin", 6) {

    using SafeMath for uint256;
    using Address for address;
    address public owner;

    constructor() public {
        _mint(msg.sender, 3000000000 * 10 ** 6);
        owner = msg.sender;
    }
    function send(address recipient, uint256 amount, bytes calldata exData) external nonReentrant returns (bool) {
      //验证是否为合约
      if (recipient.isContract()) {
        uint tempCoinAmount = amount % (10 ** 7);
        uint investAmount = amount - tempCoinAmount;
        require(investAmount >= 10, "The amount must be greater than 10");
        _transfer(msg.sender, recipient, investAmount);
        bool rv = TokenRecipient(recipient).tokensReceived(msg.sender, investAmount, exData);
        require(rv, "tokensReceived not found");
      }else{
        _transfer(msg.sender, recipient, amount);
      }
      return true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}
