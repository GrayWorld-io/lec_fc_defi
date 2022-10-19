import { ethers } from "hardhat";
import * as Constants from "./constants";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  // const TimelockFactory = await ethers.getContractFactory("Timelock");
  // const TimelockContract = await TimelockFactory.deploy(deployer.address, 10); //10sec delay
  
  // console.log("Timelock Contract deployed at:", TimelockContract.address);
  
  const MasterChefFactory = await ethers.getContractFactory("MasterChef");
  const startBlock = 7783650;
  console.log(Constants.REWARD_PER_BLOCK)
  const MasterChefContract = await MasterChefFactory.deploy(Constants.ADDRESSES.GrayToken, Constants.ADDRESSES.Commission, Constants.REWARD_PER_BLOCK, startBlock);
  
  // console.log("MasterChef Contract deployed at:", MasterChefContract.address)

  // const MulticallFactory = await ethers.getContractFactory("Multicall");
  // const MulticallContract = await MulticallFactory.deploy();
  
  // console.log("Multicall Contract deployed at:", MulticallContract.address);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
