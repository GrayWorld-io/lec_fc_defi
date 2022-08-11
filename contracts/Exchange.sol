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
        uint256 amountOut = getOutputAmount(msg.value, IERC20(token).balanceOf(address(this)), address(this).balance - msg.value);

        //transfer token out
        IERC20(token).transfer(msg.sender, amountOut);
    }
    
    function getOutputAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        uint256 numerator = (inputAmount * outputReserve);
        uint256 denominator = (inputReserve + inputAmount);
        return numerator / denominator;
    }

}

