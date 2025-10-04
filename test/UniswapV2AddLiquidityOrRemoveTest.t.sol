// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "v2-periphery/contracts/interfaces/IERC20.sol";
import {IWETH} from "v2-periphery/contracts/interfaces/IWETH.sol";
import {IUniswapV2Router02} from "v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, UNISWAP_V2_PAIR_DAI_WETH, UNISWAP_V2_ROUTER_02} from "../../../src/Constants.sol";

contract UniswapV2LiquidityTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    IUniswapV2Router02 private constant router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair private constant pair =
        IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);

    address private constant user = address(100);

    function setUp() public {
        deal(user, 100 * 1e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();

        //Fund dai
        deal(DAI, user, 1000000 * 1e18);
        vm.startPrank(user);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_addLiquidityTest() public {
        uint amountADesired = 1e6 * 1e18;
        uint amountBDesired = 100e18;
        uint amountBMin = 1;

        vm.prank(user);
        (uint amountA, uint amountB, uint liquidity) = router.addLiquidity(
            DAI,
            WETH,
            amountADesired,
            amountBDesired,
            amountBMin,
            amountBMin,
            user,
            block.timestamp
        );

        console2.log("USER AMOUNT DAI : ", amountA);
        console2.log("USER AMOUNT WETH : ", amountB);
        console2.log("USER LP : ", liquidity);
        assertGt(pair.balanceOf(user), 0, "LP = 0");
    }

    function test_removeLiquidity() public {
        vm.startPrank(user);
        //Add Liquidity
        (, , uint liquidity) = router.addLiquidity({
            tokenA: DAI,
            tokenB: WETH,
            amountADesired: 1000000 * 1e18,
            amountBDesired: 100 * 1e18,
            amountAMin: 1,
            amountBMin: 1,
            to: user,
            deadline: block.timestamp
        });

        //Remove Liquidity
        pair.approve(address(router), liquidity);
        (uint amountA, uint amountB) = router.removeLiquidity({
            tokenA: DAI,
            tokenB: WETH,
            liquidity: liquidity,
            amountAMin: 1, //Never never might cause Slippage
            amountBMin: 1,
            to: user,
            deadline: block.timestamp
        });
        vm.stopPrank();

        console2.log("USER AMOUNT DAI : ", amountA);
        console2.log("USER AMOUNT WETH : ", amountB);
        assertEq(pair.balanceOf(user), 0, "LP = 0");
    }
}

// 419514563544056931037866
// 100000000000000000000
// 3080655048278747781025
