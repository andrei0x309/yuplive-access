import { HardhatUserConfig } from "hardhat/config";
import { vars } from "hardhat/config"
import '@nomicfoundation/hardhat-toolbox'
import '@openzeppelin/hardhat-upgrades'


const PK = vars.get("PK") 

const POLYGON_MUMBAI_RPC = vars.get("POLYGON_MUMBAI_RPC")
const POLYGON_RPC = vars.get("POLYGON_RPC")

const config: HardhatUserConfig = {
  solidity: "0.8.23",
  networks: {
    mumbai: {
      url: POLYGON_MUMBAI_RPC,
      accounts: [PK]
    },
    polygon: {
      url: POLYGON_RPC,
      accounts: [PK]
    }
  },
};

export default config;

