//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IExchange.sol";

contract Exchange is ERC20 {
    event TokenPurchase(
        address indexed buyer,
        uint256 indexed ethSold,
        uint256 indexed tokensBought
    );
    event EthPurchase(
        address indexed buyer,
        uint256 indexed ethSold,
        uint256 indexed tokensBought
    );
    event AddLiquidity(
        address indexed provider,
        uint256 indexed ethAmount,
        uint256 indexed tokenAmount
    );
    event RemoveLiquidity(
        address indexed provider,
        uint256 indexed ethAmount,
        uint256 indexed tokenAmount
    );

    IERC20 token;
    IFactory factory;

    constructor(address _token) ERC20("Gray Uniswap V2", "GUNI-V2") {
        require(
            address(factory) == address(0) &&
                address(token) == address(0) &&
                _token != address(0)
        );
        token = IERC20(_token);
        factory = IFactory(msg.sender);
    }

    function addLiquidity(uint256 _maxTokens) public payable returns (uint256) {
        require(_maxTokens > 0 && msg.value > 0);
        uint256 totalLiquidity = totalSupply();
        if (totalLiquidity > 0) {
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = token.balanceOf(address(this));
            uint256 tokenAmount = (msg.value * tokenReserve) / ethReserve;
            require(_maxTokens >= tokenAmount);
            require(token.transferFrom(msg.sender, address(this), tokenAmount));
            uint256 liquidityMinted = (totalLiquidity * msg.value) / ethReserve;
            _mint(msg.sender, liquidityMinted);

            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            emit Transfer(address(0), msg.sender, liquidityMinted);

            return liquidityMinted;
        } else {
            require(
                address(factory) != address(0) &&
                    address(token) != address(0) &&
                    msg.value > 1000000000
            );
            uint256 tokenAmount = _maxTokens;
            uint256 initialLiquidity = address(this).balance;
            _mint(msg.sender, initialLiquidity);
            require(token.transferFrom(msg.sender, address(this), tokenAmount));

            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            emit Transfer(address(0), msg.sender, initialLiquidity);

            return initialLiquidity;
        }
    }

    function removeLiquidity(uint256 _lpToken)
        public
        returns (uint256, uint256)
    {
        uint256 totalLiquidity = totalSupply();
        uint256 ethAmount = (_lpToken * address(this).balance) / totalLiquidity;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenAmount = (_lpToken * tokenReserve) / totalLiquidity;

        _burn(msg.sender, _lpToken);

        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender, tokenAmount);

        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);
        emit Transfer(msg.sender, address(0), _lpToken);

        return (ethAmount, tokenAmount);
    }

    // ETH -> ERC20
    function ethToTokenSwap(uint256 _minTokens) public payable {
        ethToToken(_minTokens, msg.sender);
    }

    // ETH -> ERC20
    function ethToTokenTransfer(uint256 _minTokens, address _recipient)
        public
        payable
    {
        ethToToken(_minTokens, _recipient);
    }

    // ERC20 -> ETH
    function tokenToEthSwap(uint256 _tokenSold, uint256 _minEth) public {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 outputAmount = getOutputAmount(
            _tokenSold,
            tokenReserve,
            address(this).balance
        );

        require(outputAmount >= _minEth, "Insufficient output Amount");

        payable(msg.sender).transfer(_minEth);
        require(token.transferFrom(msg.sender, address(this), _tokenSold));
    }

    function tokenToTokenSwap(
        uint256 _tokenSold,
        uint256 _minTokenBought,
        uint256 _minEthBought,
        address _tokenAddress
    ) public {
        address toTokenExchangeAddress = factory.getExchange(_tokenAddress);

        //ERC20 -> ETH
        uint256 ethOutputAmount = getOutputAmount(
            _tokenSold,
            token.balanceOf(address(this)),
            address(this).balance
        );
        require(
            _minEthBought <= ethOutputAmount,
            "Insufficient eth output amount"
        );
        require(
            token.transferFrom(msg.sender, address(this), _tokenSold),
            "fail transfer"
        );

        //ETH -> ERC20
        IExchange(toTokenExchangeAddress).ethToTokenTransfer{
            value: ethOutputAmount
        }(_minTokenBought, msg.sender);
    }

    function ethToToken(uint256 _minTokens, address _recipient) private {
        uint256 tokenReserve = token.balanceOf(address(this));
        // calculate amount out
        uint256 outputAmount = getOutputAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        require(outputAmount >= _minTokens, "Insufficient output Amount");

        //transfer token out
        require(token.transfer(_recipient, outputAmount));

        emit TokenPurchase(_recipient, msg.value, outputAmount);
    }

    function getOutputAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 numerator = (inputAmountWithFee * outputReserve);
        uint256 denominator = (inputReserve * 100 + inputAmountWithFee);
        return numerator / denominator;
    }

    function getOutputAmountNoFee(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount;
        uint256 numerator = (inputAmountWithFee * outputReserve);
        uint256 denominator = (inputReserve + inputAmountWithFee);
        return numerator / denominator;
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
