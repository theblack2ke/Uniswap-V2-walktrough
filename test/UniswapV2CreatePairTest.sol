// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "v2-core/contracts/interfaces/IERC20.sol";
import {IWETH} from "v2-periphery/contracts/interfaces/IWETH.sol";
import {IUniswapV2Factory} from "v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, UNISWAP_V2_PAIR_DAI_WETH, UNISWAP_V2_FACTORY} from "../../../src/Constants.sol";
import {ERC20} from "src/ERC20.sol";

contract UniswapV2FactoryTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IUniswapV2Factory private constant factory =
        IUniswapV2Factory(UNISWAP_V2_FACTORY);

    function test_createPair() public {
        ERC20 enock = new ERC20("test", "TEST", 18);

        // Exercise - deploy token + WETH pair contract
        // Write your code here
        // Don’t change any other code
        // function createPair(address tokenA, address tokenB) external returns (address pair);

        address pair = factory.createPair(address(enock), address(weth));
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if (address(enock) < WETH) {
            assertEq(token0, address(enock), "token 0");
            assertEq(token1, WETH, "token 1");
        } else {
            assertEq(token0, WETH, "token 0");
            assertEq(token1, address(enock), "token 1");
        }
    }
}
