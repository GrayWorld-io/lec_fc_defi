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
        require(token.transferFrom(msg.sender, address(this), _tokenAmount));
    }
  
    // ETH -> ERC20
    function ethToTokenSwap(uint256 _minTokens) public payable {

        uint256 tokenReserve = token.balanceOf(address(this));
        // calculate amount out
        uint256 outputAmount = getOutputAmount(msg.value, address(this).balance - msg.value, tokenReserve);

        require(outputAmount >= _minTokens, "Insufficient output Amount");

        //transfer token out
        require(token.transfer(msg.sender, outputAmount));
    }

    // ERC20 -> ETH
    function tokenToEthSwap (uint256 _tokenSold, uint256 _minEth) public {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 outputAmount = getOutputAmount(_tokenSold, tokenReserve, address(this).balance);

        require(outputAmount >= _minEth, "Insufficient output Amount");

        payable(msg.sender).transfer(_minEth);
        require(token.transferFrom(msg.sender, address(this), _tokenSold));
    }
    
    function getOutputAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        uint256 numerator = (inputAmount * outputReserve);
        uint256 denominator = (inputReserve + inputAmount);
        return numerator / denominator;
    }

}

