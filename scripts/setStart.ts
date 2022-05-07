// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const composablePandas = await ethers.getContractAt(
    "WanderPandas",
    "0xE5D3C7c207fA534DfB32f52D84964A371e98ef80"
  );

  await composablePandas.setIsCPublicMintStart(true);
  await composablePandas.setIsQuarkPublicMintStart(true);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
