// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");

  // await greeter.deployed();
  //
  // console.log("Greeter deployed to:", greeter.address);

  const ERC721C = await ethers.getContractFactory("ERC721C");
  const erc721c = await ERC721C.deploy("ERC721C", "ERC721C", 2, 200);
  await erc721c.deployed();
  console.log("ERC721C deployed to:", erc721c.address);
  //
  const ERC721T = await ethers.getContractFactory("ERC721T");
  const erc721t = await ERC721T.deploy("ERC721T", "ERC721T", 2, 200);
  await erc721t.deployed();
  console.log("ERC721T deployed to:", erc721t.address);

  await erc721t.mint();
  console.log("minted erc721t");
  await erc721t.mint();
  console.log("minted erc721t");
  await erc721t.mint();
  console.log("minted erc721t");

  await erc721t.setParentAddress(erc721c.address);
  console.log("set parent address");
  await erc721c.mint1(
    [erc721t.address, erc721t.address, erc721t.address],
    [0, 1, 2]
  );
  console.log("minted erc721c");
  const res = await erc721c.getChildrenTraitMapping(0);
  const r = await res.wait();
  console.log("res", r);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
