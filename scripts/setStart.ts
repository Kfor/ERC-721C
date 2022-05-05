// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const composablePandas = await ethers.getContractAt(
    "ComposablePandas",
    "0x9e75dF3160040d85f8114b43e6cfCe5A89Dcf0b7"
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
