import { expect } from "chai";
import { ethers } from "hardhat";
import { it } from "mocha";

describe("QAddress", function () {
  it("get q address", async () => {
    const cContract = await ethers.getContractAt(
      "ComposableMatchMan",
      "0x927689f1C64f58ee0324F7F69c09Fb7cC78EC187"
    );
    console.info(await cContract.getQuarkAddress());
  });
  it("get token", async () => {
    const qContract = await ethers.getContractAt(
      "Quark",
      "0xF6EF08F15f84b881eD2377c8dE167Ed50ED95029"
    );
    console
      .info
      // await qContract(
      //   "QmPC7ZX9xKGLd7A3mqnKYXnQtGgFfEf6ZRTJerFyDLmpYA"
      // )
      ();
  });
});
