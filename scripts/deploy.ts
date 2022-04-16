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

  console.info(
    "balance1",
    await composableMatchMan.balanceOf(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    )
  );
  await composableMatchMan.joinPool(composableFactory.address);
  await composableMatchMan.mint();

  console.info(
    "balance2",
    await composableMatchMan.balanceOf(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    )
  );

  const res = await composableFactory.quarksOf(composableMatchMan.address, 0);
  console.info("tests res mint", res);
  const approved = await composableMatchMan.setApprovalForAll(
    composableFactory.address,
    true
  );
  console.info("approved", approved);

  const splitRes = await composableFactory.split(composableMatchMan.address, 0);
  console.info("splitRes", splitRes);

  console.info(
    "balance3",
    await composableMatchMan.balanceOf(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    )
  );

  const quarkAddress = await composableMatchMan.getQuarkAddress();
  const quarkEntity = await ethers.getContractAt("Quark", quarkAddress);

  // test Q after split is owned by user
  console.info(
    "balance quark1",
    await quarkEntity.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"),
    await quarkEntity.balanceOf(composableFactory.address)
  );

  const quarkApproved = await quarkEntity.setApprovalForAll(
    composableFactory.address,
    true
  );
  console.info("approved quark", quarkApproved);

  const composeRes = await composableFactory.compose(
    quarkAddress,
    [0, 1, 2, 3]
  );

  // test C after compose is owned by user
  console.info(
    "balance4",
    await composableMatchMan.balanceOf(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    )
  );
  console.info(
    "balance quark2",
    await quarkEntity.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"),
    await quarkEntity.balanceOf(composableFactory.address)
  );

  console.info("All test done!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
