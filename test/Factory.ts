import { ethers } from "hardhat"
import { expect } from "chai";

import { Exchange } from "../typechain-types/contracts/Exchange"
import { Token } from "../typechain-types/contracts/Token";
import { Factory } from "../typechain-types/contracts/Factory";

import { BigNumber } from "ethers";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());
const toEther = (value: BigNumber) => ethers.utils.formatEther(value);
const getBalance = ethers.provider.getBalance;

describe("Factory", () => {
    let owner: any;
    let user: any;
    let factory: Factory;
    let token: Token;

    beforeEach(async () => {

        //기본적으로 10,000개의 Ether를 가지고 있음.
        [owner, user] = await ethers.getSigners();
        const TokenFactory = await ethers.getContractFactory("Token");
        token = await TokenFactory.deploy("GrayToken", "GRAY", toWei(50));
        await token.deployed();

        const FactoryFactory = await ethers.getContractFactory("Factory");
        factory = await FactoryFactory.deploy();
        await factory.deployed();
    });

    describe("deploy Factory Contract", async () => {
        it("correct deploy factory", async () => {
            const exchangeAddress = await factory.callStatic.createExchange(token.address);
            console.log(exchangeAddress);
            console.log(await factory.getExchange(token.address));
            await factory.createExchange(token.address);
            expect(await factory.getExchange(token.address)).eq(exchangeAddress);
            expect(await factory.getToken(exchangeAddress)).eq(token.address);
            
        });
    });

})