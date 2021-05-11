const NFT = artifacts.require("NFT");

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const URI =
  "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg";

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test buy with mint and forSale", () => {
    return NFT.deployed().then(async (nft) => {
      let price = 10;
      let id = 1;

      await nft.mint(URI, { from: account_one });
      await nft.forSale(id, price, { from: account_one });
      await nft.buy(id, { from: account_two, value: price });

      let balance1 = await nft.balanceOf(account_one, { from: account_one });
      let balance2 = await nft.balanceOf(account_two, { from: account_two });

      assert.equal(balance1, 0, "Balance should be 0!");
      assert.equal(balance2, 1, "Balance should be 1!");
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test approve and getApproved", () => {
    return NFT.deployed().then(async (nft) => {
      let id = 1;

      await nft.mint(URI, { from: account_one });
      await nft.approve(account_two, id, { from: account_one });

      let actual = await nft.getApproved(id, { from: account_one });

      assert.equal(actual, account_two, "Account 2 should be approved!");
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test approve with burn", () => {
    return NFT.deployed().then(async (nft) => {
      let id = 1;

      let actual = await nft.balanceOf(account_one, { from: account_one });

      await nft.mint(URI, { from: account_one });
      await nft.approve(account_two, id, { from: account_one });
      await nft.burn(id, { from: account_two });

      assert.equal(actual, 0, "Should not have any NFTs!");
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test buy with not enough Ether sent", () => {
    return NFT.deployed().then(async (nft) => {
      let price = 10;
      let id = 1;

      await nft.mint(URI, { from: account_one });
      await nft.forSale(id, price, { from: account_one });

      try {
        await nft.buy(id, { from: account_two, value: price - 1 });
      } catch (ex) {
        assert.equal(
          ex.toString(),
          "Error: Returned error: VM Exception while processing transaction: revert NFT costs more -- Reason given: NFT costs more.",
          'Should throw "NFT costs more"!'
        );
      }
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test isApprovedForAll", () => {
    return NFT.deployed().then(async (nft) => {
      let actual = await nft.isApprovedForAll(account_one, account_two, {
        from: account_one,
      });
      assert.equal(actual, false, "Account 2 should not be an operator!");
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test setApprovalForAll with isApprovedForAll", () => {
    return NFT.deployed().then(async (nft) => {
      await nft.setApprovalForAll(account_two, true, { from: account_one });
      let actual1 = await nft.isApprovedForAll(account_one, account_two, {
        from: account_one,
      });
      assert.equal(actual1, true, "Account 2 should be an operator!");

      await nft.setApprovalForAll(account_two, false, { from: account_one });
      let actual2 = await nft.isApprovedForAll(account_one, account_two, {
        from: account_one,
      });
      assert.equal(actual2, false, "Account 2 should not be an operator!");
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test safeTransferFrom not authorized", () => {
    return NFT.deployed().then(async (nft) => {
      try {
        let id = 1;
        await nft.mint(URI, { from: account_one });
        await nft.safeTransferFrom(account_one, account_two, id, {
          from: account_two,
        });
      } catch (ex) {
        assert.equal(
          ex.toString(),
          "Error: Returned error: VM Exception while processing transaction: revert Not owner, approved or operator -- Reason given: Not owner, approved or operator.",
          "Should throw on unauthorized call!"
        );
      }
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test safeTransferFrom when owner is not same as from parameter", () => {
    return NFT.deployed().then(async (nft) => {
      try {
        let id = 1;
        await nft.mint(URI, { from: account_one });
        await nft.safeTransferFrom(account_two, account_one, id, {
          from: account_one,
        });
      } catch (ex) {
        assert.equal(
          ex.toString(),
          "Error: Returned error: VM Exception while processing transaction: revert Not owner -- Reason given: Not owner.",
          "Should throw when owner is not same as from parameter!"
        );
      }
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];

  it("Test safeTransferFrom with zero address", () => {
    return NFT.deployed().then(async (nft) => {
      try {
        let id = 1;
        await nft.mint(URI, { from: account_one });
        await nft.safeTransferFrom(account_one, ZERO_ADDRESS, id, {
          from: account_one,
        });
      } catch (ex) {
        assert.equal(
          ex.toString(),
          "Error: Returned error: VM Exception while processing transaction: revert Zero address -- Reason given: Zero address.",
          "Should throw when given zero address!"
        );
      }
    });
  });
});

contract("NFT", function (accounts) {
  const account_one = accounts[0];
  const account_two = accounts[1];

  it("Test transferFrom", () => {
    return NFT.deployed().then(async (nft) => {
      let id = 1;

      await nft.mint(URI, { from: account_one });
      await nft.safeTransferFrom(account_one, account_two, id, {
        from: account_one,
      });

      let balance1 = await nft.balanceOf(account_one, { from: account_one });
      let balance2 = await nft.balanceOf(account_two, { from: account_two });

      assert.equal(balance1, 0, "Balance should be 0!");
      assert.equal(balance2, 1, "Balance should be 1!");
    });
  });
});
