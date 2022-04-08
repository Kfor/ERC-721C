import { expect } from "chai";
import { ethers } from "hardhat";

describe("testERC721CT", () => {
  it("testERC721T", async () => {
    const TestERC721T = await ethers.getContractFactory("ERC721T");
    const testERC721T = await TestERC721T.deploy("namet", "symbolt", 1000, 999);
    await testERC721T.deployed();
  });


  it("testERC721C", async () => {
    const TestERC721C = await ethers.getContractFactory("ERC721C");
    const testERC721C = await TestERC721C.deploy("namec", "symbolc", 1000, 999);
    await testERC721C.deployed();
  });
});
