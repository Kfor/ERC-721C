// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const ComposableFactory = await ethers.getContractFactory(
    "ComposableFactory"
  );
  const composableFactory = await ComposableFactory.deploy();
  await composableFactory.deployed();
  console.log("ComposableFactory deployed to:", composableFactory.address);
  const ComposablePandas = await ethers.getContractFactory("ComposablePandas");
  const composablePandas = await ComposablePandas.deploy(
    "ComposablePandas",
    "ERC721C",
    10,
    10,
    15,
    composableFactory.address
  );
  await composablePandas.deployed();
  console.log("ERC721C deployed to:", composablePandas.address);
  console.log("Q address", await composablePandas.getQuarkAddress());

  const txn = await composablePandas.mint();
  await txn.wait();
  console.log("Minted");
  const res = await composableFactory.quarksOf(composablePandas.address, 0);
  console.info("Quarks of 0:", res);
  await composablePandas.setQuarkBaseURI(
    "ipfs://QmY3Cs4DpzVwbbqYDPAFRVeTiLs8VbXZbBJdEN47bx2enG/"
  );
  await composablePandas.setBaseURI(
    `https://composable-match-man.vercel.app/api/metadata/`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
