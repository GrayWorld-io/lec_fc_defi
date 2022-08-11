import { ethers } from "hardhat"
import { expect } from "chai";

import { Exchange } from "../typechain-types/contracts/Exchange"
import { Token } from "../typechain-types/contracts/Token";
import { BigNumber } from "ethers";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());
const toEther = (value: BigNumber) => ethers.utils.formatEther(value);
const getBalance = ethers.provider.getBalance;

describe("Exchange", () => {
    let owner: any;
    let user: any;
    let exchange: Exchange;
    let token: Token;

    beforeEach(async () => {

        //기본적으로 10,000개의 Ether를 가지고 있음.
        [owner, user] = await ethers.getSigners();
        const TokenFactory = await ethers.getContractFactory("Token");
        token = await TokenFactory.deploy("GrayToken", "GRAY", toWei(1000000));
        await token.deployed();

        const ExchangeFactory = await ethers.getContractFactory("Exchange");
        exchange = await ExchangeFactory.deploy(token.address);
        await exchange.deployed();
    });

    describe("addLiquidity", async () => {
        it("add liquidity", async () => {
          await token.approve(exchange.address, toWei(1000));
          await exchange.addLiquidity(toWei(1000), { value: toWei(1000) });
          expect(await getBalance(exchange.address)).to.equal(toWei(1000));
          expect(await token.balanceOf(exchange.address)).to.equal(toWei(1000));
        });
      });

    describe("getTokenPrice", async() => {
        it("correct get Token Price", async() => {
            await token.approve(exchange.address, toWei(1000));
            await exchange.addLiquidity(toWei(1000), { value: toWei(1000) });
            
            const tokenReserve = await token.balanceOf(exchange.address);
            const etherReserve = await getBalance(exchange.address);

            // GRAY Price
            // Expect 1ETH per 1GRAY
            expect(
                (await exchange.getPrice(tokenReserve, etherReserve))
            ).to.eq(1);
        })
    })

    describe("EthToTokenSwap", async() => {
        it("correct EthToTokenSwap", async() => {

            await token.approve(exchange.address, toWei(1000));
            await exchange.addLiquidity(toWei(1000), { value: toWei(1000) });
      
            await exchange.connect(user).ethToTokenSwap({ value: toWei(1) });

            expect(
                (toEther(await token.balanceOf(user.address)))
            ).to.eq("1.0");

            expect(
                (toEther(await token.balanceOf(exchange.address)))
            ).to.eq("999.0");

            expect(
                (toEther(await getBalance(exchange.address)))
            ).to.eq("1001.0");
            
        })
    })
})