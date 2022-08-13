//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    IERC20 token;

    constructor (address _token) ERC20("Gray Uniswap V2", "GUNI-V2") {
        token = IERC20(_token);
    }
    
    function addLiquidity(uint256 _maxTokens) public payable returns (uint256) {
        uint256 totalLiquidity = totalSupply();
        if (totalLiquidity > 0) {
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = token.balanceOf(address(this));
            uint256 tokenAmount = msg.value * tokenReserve / ethReserve;
            require(_maxTokens >= tokenAmount);
            require(token.transferFrom(msg.sender, address(this), tokenAmount));
            uint256 liquidityMinted = totalLiquidity * msg.value / ethReserve;
            _mint(msg.sender, liquidityMinted);
            return liquidityMinted;
        } else {
            uint256 tokenAmount = _maxTokens;
            uint256 initialLiquidity = address(this).balance;
            _mint(msg.sender, initialLiquidity);
            require(token.transferFrom(msg.sender, address(this), tokenAmount));
            return initialLiquidity;
        }
    }

    function removeLiquidity(uint256 _lpToken) public returns (uint256, uint256) {
        uint256 totalLiquidity = totalSupply();
        uint256 ethAmount = _lpToken * address(this).balance / totalLiquidity;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenAmount = _lpToken * tokenReserve / totalLiquidity;

        _burn(msg.sender, _lpToken);

        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender, tokenAmount);
        return (ethAmount, tokenAmount);
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
        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 numerator = (inputAmountWithFee * outputReserve);
        uint256 denominator = (inputReserve * 100 + inputAmountWithFee);
        return numerator / denominator;
    }

    function getOutputAmountNoFee(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount;
        uint256 numerator = (inputAmountWithFee * outputReserve);
        uint256 denominator = (inputReserve + inputAmountWithFee);
        return numerator / denominator;
    }

}

