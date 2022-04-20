import { expect } from "chai";
import { ethers } from "hardhat";
import { it } from "mocha";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const signers = await ethers.getSigners();
    const primaryAccount = signers[0];

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
      await composableMatchMan.balanceOf(primaryAccount.address)
    );
    await composableMatchMan.joinPool(composableFactory.address);
    await composableMatchMan.mint();
    await composableMatchMan.mint();
    await composableMatchMan.mint();

    console.info(
      "balance2",
      await composableMatchMan.balanceOf(primaryAccount.address)
    );

    const res = await composableFactory.quarksOf(composableMatchMan.address, 0);
    console.info("tests res mint", res);
    const approved = await composableMatchMan.setApprovalForAll(
      composableFactory.address,
      true
    );
    console.info("approved", approved);

    const splitRes = await composableFactory.split(
      composableMatchMan.address,
      1
    );
    console.info("splitRes", splitRes);

    const balance = await composableMatchMan.balanceOf(primaryAccount.address);
    console.info("balance3", balance);

    const ttt = await composableMatchMan.tokenOfOwnerByIndex(
      primaryAccount.address,
      0
    );
    const ttt1 = await composableMatchMan.tokenOfOwnerByIndex(
      primaryAccount.address,
      1
    );
    console.info("ttt", ttt, ttt1);

    const quarkAddress = await composableMatchMan.getQuarkAddress();
    const quarkEntity = await ethers.getContractAt("Quark", quarkAddress);

    // test Q after split is owned by user
    console.info(
      "balance quark1",
      await quarkEntity.balanceOf(primaryAccount.address),
      await quarkEntity.balanceOf(composableFactory.address)
    );

    const quarkApproved = await quarkEntity.setApprovalForAll(
      composableFactory.address,
      true
    );
    console.info("approved quark", quarkApproved);
    //
    // const composeRes = await composableFactory.compose(
    //   quarkAddress,
    //   [1, 2, 3, 4]
    // );
    //
    // // test C after compose is owned by user
    // console.info(
    //   "balance4",
    //   await composableMatchMan.balanceOf(primaryAccount.address)
    // );
    // console.info(
    //   "balance quark2",
    //   await quarkEntity.balanceOf(primaryAccount.address),
    //   await quarkEntity.balanceOf(composableFactory.address)
    // );
    //
    // console.info("All test done!");
  });
});
