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
          await token.approve(exchange.address, toWei(500));
          await exchange.addLiquidity(toWei(500), { value: toWei(300) });
          expect(await getBalance(exchange.address)).to.equal(toWei(300));
          expect(await token.balanceOf(exchange.address)).to.equal(toWei(500));
        });
      });

    describe("getTokenAmount", async() => {
        it("correct get Token output amount", async() => {
            await token.approve(exchange.address, toWei(4000));
            await exchange.addLiquidity(toWei(4000), { value: toWei(1000) });
            
            const tokenReserve = await token.balanceOf(exchange.address);
            const etherReserve = await getBalance(exchange.address);
            
            expect(
                toEther((await exchange.getOutputAmount(toWei(1), etherReserve, tokenReserve)))
            ).to.eq("3.996003996003996003");

            expect(
                toEther((await exchange.getOutputAmount(toWei(1000), etherReserve, tokenReserve)))
            ).to.eq("2000.0");

            expect(
                toEther((await exchange.getOutputAmount(toWei(2000), etherReserve, tokenReserve)))
            ).to.eq("2666.666666666666666666");

            expect(
                toEther((await exchange.getOutputAmount(toWei(4000), etherReserve, tokenReserve)))
            ).to.eq("3200.0");

            expect(
                toEther((await exchange.getOutputAmount(toWei(20000), etherReserve, tokenReserve)))
            ).to.eq("3809.523809523809523809");

            expect(
                toEther((await exchange.getOutputAmount(toWei(1000000), etherReserve, tokenReserve)))
            ).to.eq("3996.003996003996003996");

        })
    })

    describe("getEthAmount", async() => {
        it("correct get Eth output amount", async() => {
            await token.approve(exchange.address, toWei(4000));
            await exchange.addLiquidity(toWei(4000), { value: toWei(1000) });
            
            const tokenReserve = await token.balanceOf(exchange.address);
            const etherReserve = await getBalance(exchange.address);
            
            expect(
                toEther((await exchange.getOutputAmount(toWei(1), tokenReserve, etherReserve)))
            ).to.eq("0.249937515621094726");

        })
    })

    describe("EthToTokenSwap", async() => {
        it("correct EthToTokenSwap", async() => {

            await token.approve(exchange.address, toWei(4000));
            await exchange.addLiquidity(toWei(4000), { value: toWei(1000) });
      
            await exchange.connect(user).ethToTokenSwap(toWei(3.99), { value: toWei(1) });

            expect(
                (toEther(await token.balanceOf(user.address)))
            ).to.eq("3.996003996003996003");
        })
    })

    describe("tokenToEthSwap", async() => {
        it("correct tokenToTehSwap", async() => {

            await token.transfer(user.address, toWei(100));
            //나의 토큰을 Exchange Contract가 가져 갈 수 있도록 approve.
            await token.connect(user).approve(exchange.address, toWei(100));
      
            await token.approve(exchange.address, toWei(4000));
            await exchange.addLiquidity(toWei(4000), { value: toWei(1000) });
            
            const userBalanceBeforeSwap = await getBalance(user.address);
            await exchange.connect(user).tokenToEthSwap(toWei(4), toWei(0.99) );
            const userBalanceAfterSwap = await getBalance(user.address);

            // Require set gas price on 'hardhat.config.ts' to pass this test.
            expect(
                (toEther(userBalanceAfterSwap.sub(userBalanceBeforeSwap)).toString())
            ).to.eq("0.989948634");
        })
    })
})