
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin-4/contracts/utils/math/SafeMath.sol";
import "@openzeppelin-4/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin-4/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin-4/contracts/access/Ownable.sol";


interface I8Spirit {
    function depositFor(address _user, uint256 _amount) external;
}

interface IBaseRouter {
    function swapExactTokensForTokensSimple(uint256 amountIn, uint256 amountOutMin, address tokenFrom, address tokenTo, bool stable, address to, uint256 deadline) external returns (uint256 amount);
}

interface IBasePair {
    function getAmountOut(uint256 amountIn, address tokenIn) external view returns(uint256 amountOut);
}

contract 8SpiritFactory is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // needed addresses
    address public 8Spirit;
    address public spirit;
    address public pair;
    address public router;  

    constructor(
        address _8Spirit,
        address _spirit,
        address _pair,
        address _router
    ) {
        8Spirit = _8Spirit;
        spirit = _spirit;
        pair = _pair;
        router = _router;
        

        IERC20(spirit).safeApprove(router, type(uint256).max);
        IERC20(spirit).safeApprove(8Spirit, type(uint256).max);
    }

    function depositAll() external {
        uint256 userBal = IERC20(spirit).balanceOf(msg.sender);
        deposit(userBal);
    }

    function deposit(uint256 _amount) public {
        IERC20(spirit).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 swapAmount = IBasePair(pair).getAmountOut(_amount, spirit);

        if (swapAmount > _amount) {
            IBaseRouter(router).swapExactTokensForTokensSimple(_amount, swapAmount, spirit, binSpirit, true, msg.sender, block.timestamp);
        } else {
            I8Spirit(binSpirit).depositFor(msg.sender, _amount);
        }
    }

     // recover any tokens sent on error
    function inCaseTokensGetStuck(address _token) external onlyOwner {
            uint256 _amount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _amount);
    }
}