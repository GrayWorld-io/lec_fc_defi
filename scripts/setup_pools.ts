import { ethers } from "hardhat";
import { Interface } from '@ethersproject/abi'
import { arrayify } from "ethers/lib/utils";

import * as MasterChefConstants from "./constants";
import { ADDRESSES } from "./constants";
import { MasterChef__factory } from "../typechain-types";

async function main() {

    const TimelockFactory = await ethers.getContractFactory("Timelock");
    const TimelockContract = await TimelockFactory.attach(ADDRESSES.Timelock);

    const allocPoint = MasterChefConstants.POOL_ADD_ETH_GRAY_ALLOC_POINT;
    const lpAddress = MasterChefConstants.POOL_ADD_ETH_GRAY_PAIR_ADDRESS;
    // const allocPoint = MasterChefConstants.POOL_ADD_ETH_GUSD_ALLOC_POINT;
    // const lpAddress = MasterChefConstants.POOL_ADD_ETH_GUSD_PAIR_ADDRESS;

    const itf = new Interface(MasterChef__factory.abi);
    const encodedData = itf.encodeFunctionData(MasterChefConstants.POOL_ADD_FUNCTION, [allocPoint, lpAddress, false])

    /*
        target: MasterChef Address
        value: 0
        function signature: add(uint256,address,bool)
        data(function parameter): '0x' + callData.substring(10)
        eta: timestamp
    */
    const targetAddress = ADDRESSES.Masterchef;
    const functionSignature = MasterChefConstants.POOL_ADD_FUNCTION_SIGNATURE;
    const callData = arrayify('0x' + encodedData.substring(10));
    const targetTimeStamp = 1664785458;
    // await TimelockContract.queueTransaction(targetAddress, 0, functionSignature, callData, targetTimeStamp);
    await TimelockContract.executeTransaction(targetAddress, 0, functionSignature, callData, targetTimeStamp);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
