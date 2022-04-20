import { expect } from "chai";
import { ethers } from "hardhat";
import { it } from "mocha";

describe("set base uri", function () {
  it("set c base uri", async () => {
    const cContract = await ethers.getContractAt(
      "ComposableMatchMan",
      "0x1266f086e0f17Ab5A81fafcf2178d5a2404954A1"
    );
    console.info(await cContract.getQuarkAddress());
  });

  it("set q base uri", async () => {
    const cContract = await ethers.getContractAt(
      "ComposableMatchMan",
      "0x1266f086e0f17Ab5A81fafcf2178d5a2404954A1"
    );
    console.info(
      await cContract.setQuarkBaseURI(
        "ipfs://QmS3beks3GhSbYuXPTeHv6EiELcg23hoBSQQXcxtS3fd3Z/"
      )
    );
  });
});
