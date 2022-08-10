import { ethers } from "hardhat"
import { expect } from "chai";

import { Exchange } from "../typechain-types/contracts/Exchange"
import { Token } from "../typechain-types/contracts/Token";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());

const getBalance = ethers.provider.getBalance;

describe("Exchange", () => {
    let owner: any;
    let user: any;
    let exchange: Exchange;
    let token: Token;

    beforeEach(async () => {
        [owner, user] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("Token");
        token = await TokenFactory.deploy("Token", "TKN", toWei(1000000));
        await token.deployed();

        const ExchangeFactory = await ethers.getContractFactory("Exchange");
        exchange = await ExchangeFactory.deploy(token.address);
        await exchange.deployed();
    });

    describe("addLiquidity", async () => {
        it("adds liquidity", async () => {
          await token.approve(exchange.address, toWei(200));
          await exchange.addLiquidity(toWei(200), { value: toWei(100) });
    
          expect(await getBalance(exchange.address)).to.equal(toWei(100));
          expect(await token.balanceOf(exchange.address)).to.equal(toWei(200));
        });
      });
})