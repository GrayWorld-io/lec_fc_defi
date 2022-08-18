//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface IFactory {
    function getExchange(address _token) external returns (address);

}