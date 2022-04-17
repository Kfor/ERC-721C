// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const ComposableMatchMan = await ethers.getContractFactory(
    "ComposableMatchMan"
  );
  const composableMatchMan = await ComposableMatchMan.deploy(
    "ComposableMatchMan",
    "ERC721C",
    2,
    200,
    20
  );
  await composableMatchMan.deployed();
  console.log("ERC721C deployed to:", composableMatchMan.address);
  const ComposableFactory = await ethers.getContractFactory(
    "ComposableFactory"
  );
  const composableFactory = await ComposableFactory.deploy();
  await composableFactory.deployed();
  console.log("ComposableFactory deployed to:", composableFactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
