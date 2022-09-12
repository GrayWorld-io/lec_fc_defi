import { ethers } from "hardhat"
import { expect } from "chai";

import { StakingRewards } from "../typechain-types";
import { Exchange } from "../typechain-types/contracts/Exchange"
import { Token } from "../typechain-types/contracts/Token";
import { Factory } from "../typechain-types/contracts/Factory";

import { BigNumber } from "ethers";

const toWei = (value: number) => ethers.utils.parseEther(value.toString());
const toEther = (value: BigNumber) => ethers.utils.formatEther(value);
const getBalance = ethers.provider.getBalance;

describe("StakingRewards", () => {
    let owner: any;
    let user: any;
    let token: Token;
    let stakingRewards: StakingRewards;

    beforeEach(async () => {

        // //기본적으로 10,000개의 Ether를 가지고 있음.
        // [owner, user] = await ethers.getSigners();
        // const TokenFactory = await ethers.getContractFactory("Token");
        // token = await TokenFactory.deploy("GrayToken", "GRAY", toWei(100000));
        // await token.deployed();

        // const StakingRewardsFactory = await ethers.getContractFactory("StakingRewards");
        // stakingRewards = await StakingRewardsFactory.deploy(token.address, token.address);
        // await stakingRewards.deployed();


    });

    describe("do stake", async () => {
        it("do stake correct", async () => {

        const sevenDays = 7 * 24 * 60 * 60;
        const blockNumBefore = await ethers.provider.getBlockNumber();
        const blockBefore = await ethers.provider.getBlock(blockNumBefore);
        const timestampBefore = blockBefore.timestamp;
        await mineBlocks(timestampBefore, 5);
        const blockNumAfter = await ethers.provider.getBlockNumber();
        const blockAfter = await ethers.provider.getBlock(blockNumAfter);
        const timestampAfter = blockAfter.timestamp;
        expect(blockNumAfter).to.be.equal(blockNumBefore + 5);
        expect(timestampAfter).to.be.equal(timestampBefore + 5);

        });
    });

    async function mineBlocks(timestamp: number, times: number) {
        for ( var i = 0; i < times; i++) {
            await ethers.provider.send('evm_mine',[timestamp+i+1]);
        }
    }
    // describe.skip("removeLiquidity", async () => {
    //     it("correct remove liquidity", async () => {
    //         await token.approve(exchange.address, toWei(500));
    //         await exchange.addLiquidity(toWei(500), { value: toWei(1000) });
    //         expect(await getBalance(exchange.address)).to.equal(toWei(1000));
    //         expect(await token.balanceOf(exchange.address)).to.equal(toWei(500));
    //         expect(await exchange.balanceOf(owner.address)).to.equal(toWei(1000));


    //         await token.transfer(user.address, toWei(2000));
    //         //나의 토큰을 Exchange Contract가 가져 갈 수 있도록 approve.
    //         await token.connect(user).approve(exchange.address, toWei(100));
    //         await exchange.connect(user).addLiquidity(toWei(100), { value: toWei(200)});
    //         expect(await token.balanceOf(exchange.address)).to.equal(toWei(600));

    //         await exchange.removeLiquidity(toWei(600))
    //         expect(await token.balanceOf(exchange.address)).to.equal(toWei(300));
    //     });
    // });


})