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
        uint256 inputAmount = msg.value;
        // calculate amount out (zero fee)
        uint256 outputAmount = inputAmount;
        //transfer token out
        IERC20(token).transfer(msg.sender, outputAmount);
    }

    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        uint256 numerator = inputReserve;
        uint256 denominator = outputReserve;
        return numerator / denominator;
    }

}

