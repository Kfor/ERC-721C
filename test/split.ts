import { expect } from "chai";
import { ethers } from "hardhat";
import { it } from "mocha";
import { BigNumber } from "ethers";

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
      7
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

    await composableFactory.split(composableMatchMan.address, 1);
    console.info("splitRes");

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

    // quark
    const quarkAddress = await composableMatchMan.getQuarkAddress();
    const quarkEntity = await ethers.getContractAt("Quark", quarkAddress);

    // test Q after split is owned by user
    console.info(
      "balance quark1",
      await quarkEntity.balanceOf(primaryAccount.address),
      await quarkEntity.balanceOf(composableFactory.address)
    );

    await quarkEntity.setApprovalForAll(composableFactory.address, true);
    console.info("approved quark");

    const qBalance = await quarkEntity.balanceOf(primaryAccount.address);
    console.info("qBalance", qBalance);
    for (let i = 0; i < Number(qBalance); i++) {
      console.info(
        await quarkEntity.tokenOfOwnerByIndex(primaryAccount.address, i),
        "own quark id"
      );
    }

    await composableFactory.compose(quarkAddress, [8, 9, 10, 11]);

    console.info("composeRes");
    // test C after compose is owned by user
    const balance4 = await composableMatchMan.balanceOf(primaryAccount.address);
    console.info("balance4", balance4);
    console.info(
      "balance quark2",
      await quarkEntity.balanceOf(primaryAccount.address),
      await quarkEntity.balanceOf(composableFactory.address)
    );

    for (let i = 0; i < Number(balance4); i++) {
      console.info(
        await composableMatchMan.tokenOfOwnerByIndex(primaryAccount.address, i),
        "own cmm id"
      );
    }
    console.info(await composableMatchMan.getLayerCount(), "layer count");

    await composableFactory.split(composableMatchMan.address, 3);

    // console.info("All test done!");
  });
});
