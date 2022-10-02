import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      gas: 10000000,
      gasPrice: 875000000
    },
    rinkeby: {
      url: 'https://eth-rinkeby.alchemyapi.io/v2/QTf8Pk_9sggTwzU7pA-V3Ttxe3-N1XOX',
      accounts: ['54f5584dc94d45a3989ee95e01e179fc175e65700f8051c9506d41fa74b19461']
    }
  },
  etherscan: {
    apiKey: "PDAEPYQ5KSCXNAI5Q82UU8S7GSGJ8CYC1Z"
  }
};

export default config;
