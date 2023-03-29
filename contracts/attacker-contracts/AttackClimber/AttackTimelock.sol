import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";

contract AttackClimber {
    address owner;
    address token;

    constructor(address _owner, address _token) {
        owner = _owner;
        token = _token;
    }

    function attack() public {}

    receive() external payable {}
}
