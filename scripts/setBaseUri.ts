// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const composablePandas = await ethers.getContractAt(
    "WanderPandas",
    "0x51Eab00028B0569398EDD671882f8b679200DA05"
  );

  await composablePandas.setBaseURI(
    `https://composable-pandas.vercel.app/api/metadata/`
  );
  await composablePandas.setContractURI(
    ""
  );
  await composablePandas.setQuarkContractURI(
    "https://composable-pandas.vercel.app/api/contractURI"
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
