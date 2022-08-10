//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    IERC20 token;

    constructor (address _token) {
        token = IERC20(_token);
    }
    
    function addLiquidity(uint256 _tokenAmount) public payable {
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }
  
    // ETH -> ERC20
    function ethToTokenSwap() public payable {
        // calculate amount out
        uint256 amountOut = msg.value * getPrice(address(this).balance - msg.value, IERC20(token).balanceOf(address(this)));

        //transfer token out
        IERC20(token).transfer(msg.sender, amountOut);
    }

    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        uint256 numerator = inputReserve * 1000;
        uint256 denominator = outputReserve;
        return numerator / denominator;
    }

}

