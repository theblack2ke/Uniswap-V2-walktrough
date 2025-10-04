// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "v2-core/contracts/interfaces/IERC20.sol";
import {IWETH} from "v2-periphery/contracts/interfaces/IWETH.sol";
import {IUniswapV2Router02} from "v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, MKR, UNISWAP_V2_PAIR_DAI_MKR, UNISWAP_V2_ROUTER_02} from "src/Constants.sol";

contract UniswapV2SwapTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant mkr = IERC20(MKR);

    IUniswapV2Router02 private constant router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair private constant pair =
        IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_MKR);

    address private constant user = address(100);

    function setUp() public {
        vm.startPrank(user);
        deal(user, 100 * 1e18);
        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();

        //Give liquidity to DAI and MKR
        deal(DAI, address(pair), 1e6 * 1e18);
        deal(MKR, address(pair), 1e6 * 1e18);
        pair.sync();
    }

    function test_swapExactTokensForTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountIn = 1e18;
        uint amountOutMin = 1;

        vm.prank(user);
        uint[] memory amounts = router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: user,
            deadline: block.timestamp
        });

        assertGe(mkr.balanceOf(user), amountOutMin, "MKR balance of user");
        console2.log("User MKR balance", mkr.balanceOf(user));
        console2.log("WETH", amounts[0]);
        console2.log("DAI", amounts[1]);
        console2.log("MKR", amounts[2]);
    }

    function test_swapTokensForExactTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountInMax = 0.1 * 1e18;
        uint amountOut = 1e18;

        vm.prank(user);
        uint[] memory amounts = router.swapTokensForExactTokens({
            amountOut: amountOut,
            amountInMax: amountInMax,
            path: path,
            to: user,
            deadline: block.timestamp
        });

        assertEq(mkr.balanceOf(user), amountOut, "MKR balance of user");
        console2.log("WETH", amounts[0]);
        console2.log("DAI", amounts[1]);
        console2.log("MKR", amounts[2]);
    }
}
