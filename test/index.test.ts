import { describe } from "mocha";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { expect } from "chai";
import { parseEther } from "ethers/lib/utils";
import { expectException } from "../utils/expectExpect";

describe("ERC721C", function () {
  let primaryAccount: SignerWithAddress;
  let testMintAccount: SignerWithAddress;
  let composablePandasContract: Contract;
  let composableFactoryContract: Contract;
  let quarkContract: Contract;
  const maxBatchSize = 2;
  const userMintCollectionSize = 200;
  const layerCount = 20;
  const composeQIds = [2, 3, 5];

  before("Setup", async function () {
    // Set Primary Account
    const signers = await ethers.getSigners();
    primaryAccount = signers[0];
    testMintAccount = signers[1];
    console.info(`Primary Account: ${primaryAccount.address}`);
    console.info(`Test Mint Account: ${testMintAccount.address}`);
    // Deploy C, Q and F
    const ComposableFactory = await ethers.getContractFactory(
      "ComposableFactory"
    );
    composableFactoryContract = await ComposableFactory.deploy();
    await composableFactoryContract.deployed();
    const ComposablePandas = await ethers.getContractFactory(
      "ComposablePandas"
    );
    composablePandasContract = await ComposablePandas.deploy(
      "ComposablePandas",
      "ERC721C",
      maxBatchSize,
      userMintCollectionSize,
      layerCount,
      composableFactoryContract.address
    );
    await composablePandasContract.deployed();
    console.log("C:",composablePandasContract.address);

    // Get Q address
    const quarkAddress = await composablePandasContract.getQuarkAddress();
    quarkContract = await ethers.getContractAt("Quark", quarkAddress);
    console.log("Q:",quarkAddress);

    // Set base uri
    await composablePandasContract.setBaseURI(
      `https://composable-match-man.vercel.app/api/metadata/`
    );
    await composablePandasContract.setQuarkBaseURI(
      "ipfs://QmS3beks3GhSbYuXPTeHv6EiELcg23hoBSQQXcxtS3fd3Z/"
    );
  });
  describe("Mint", async function () {
    it("Should be 0 for Quark and C totalSupply", async function () {
      const cTotalSupply = await composablePandasContract.totalSupply();
      expect(cTotalSupply.toNumber()).to.equal(0);

      const qTotalSupply = await quarkContract.totalSupply();
      expect(qTotalSupply.toNumber()).to.equal(0);
    });
    it("Should be 0 for Quark and C for primary account when init", async function () {
      const quarkBalance = await quarkContract.balanceOf(
        primaryAccount.address
      );
      expect(quarkBalance.toNumber()).to.equal(0);
      const cBalance = await composablePandasContract.balanceOf(
        primaryAccount.address
      );
      expect(cBalance.toNumber()).to.equal(0);
    });
    it("Should allow mint", async function () {
      await composablePandasContract.reserveMint(1);
      const cBalance = await composablePandasContract.balanceOf(
        primaryAccount.address
      );
      expect(cBalance.toNumber()).to.equal(1);
    });
  });
  describe("Split", async function () {
    before("Set approve for all", async function () {
      await composablePandasContract.setApprovalForAll(
        composableFactoryContract.address,
        true
      );
      const approvedCMM = await composablePandasContract.isApprovedForAll(
        primaryAccount.address,
        composableFactoryContract.address
      );
      expect(approvedCMM).to.equal(true);
      await quarkContract.setApprovalForAll(
        composableFactoryContract.address,
        true
      );
      const approveQuark = await quarkContract.isApprovedForAll(
        primaryAccount.address,
        composableFactoryContract.address
      );
      expect(approveQuark).to.equal(true);
    });
    it("Should be able to split and balance of C and Q should be 0 and layerCount", async function () {
      await composableFactoryContract.split(
        composablePandasContract.address,
        0
      );
      const balanceOfC = await composablePandasContract.balanceOf(
        primaryAccount.address
      );
      expect(balanceOfC.toNumber()).to.equal(0);
      const balanceOfQ = await quarkContract.balanceOf(primaryAccount.address);
      expect(balanceOfQ.toNumber()).to.equal(layerCount);
    });
    it("Should be able to compose and balance should change", async function () {
      await composableFactoryContract.compose(
        quarkContract.address,
        composeQIds
      );
      const balanceOfC = await composablePandasContract.balanceOf(
        primaryAccount.address
      );
      expect(balanceOfC.toNumber()).to.equal(1);
      const balanceOfQ = await quarkContract.balanceOf(primaryAccount.address);
      expect(balanceOfQ.toNumber()).to.equal(layerCount - composeQIds.length);
    });
    it("Should be able to re split", async function () {
      await composableFactoryContract.split(
        composablePandasContract.address,
        1
      );
      const balanceOfC = await composablePandasContract.balanceOf(
        primaryAccount.address
      );
      expect(balanceOfC.toNumber()).to.equal(0);
      const balanceOfQ = await quarkContract.balanceOf(primaryAccount.address);
      expect(balanceOfQ.toNumber()).to.equal(layerCount);
    });
  });
  describe("Public Mint", async function () {
    before("Link Test Account", async function () {
      composablePandasContract = await composablePandasContract.connect(
        testMintAccount
      );
    });
    it("Should not be available before set started", async function () {
      await expectException(
        composablePandasContract.publicMintC(2, {
          value: parseEther("0.1"),
        }),
        "not started"
      );
      await expectException(
        composablePandasContract.publicMintBatchQ(2),
        "not started"
      );
    });
    it("Mint C", async function () {
      await composablePandasContract
        .connect(primaryAccount)
        .setIsCPublicMintStart(true);
      await composablePandasContract.publicMintC(2, {
        value: parseEther("0.1"),
      });
    });
    it("Mint Q", async function () {
      await composablePandasContract
        .connect(primaryAccount)
        .setIsQuarkPublicMintStart(true);
      await composablePandasContract.publicMintBatchQ(2);
    });
    it("Reserve Mint Q", async function () {
      await composablePandasContract
        .connect(primaryAccount)
        .reserveMintBatchQ(20);
    });
  });
  describe("WithDraw", async function () {
    before("Link Test Account", async function () {
      composablePandasContract = await composablePandasContract.connect(
        primaryAccount
      );
    });
    it("with draw C", async function () {
      await composablePandasContract
        .connect(primaryAccount)
        .withdraw();
    });
  });
});
