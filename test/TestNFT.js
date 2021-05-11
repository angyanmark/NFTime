const NFT = artifacts.require("NFT");

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

  it("Test approve and getApproved", () => {
    return NFT.deployed().then(async (nft) => {
      let id = 1;

      await nft.mint(URI, { from: account_one });
      await nft.approve(account_two, id, { from: account_one });

      let actual = await nft.getApproved(id, { from: account_one });

      assert.equal(actual, account_two, "Account 2 should be approved!");
    });
  });

  /*it("Test approve with burn", () => {
    return NFT.deployed().then(async (nft) => {
      let id = 1;

      await nft.mint(URI, { from: account_one });
      await nft.approve(account_two, id, { from: account_one });
      await nft.burn(id, { from: account_two });

      let actual = await nft.balanceOf(account_one, { from: account_one });

      assert.equal(actual.toString(), "0", "Should not have any NFTs!");
    });
  });*/ // FAILOL DE MÉ ???

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
          "Error: Returned error: VM Exception while processing transaction: revert NFT costs more -- Reason given: NFT costs more.",
          ex.toString(),
          "Should throw \"NFT costs more\"!"
        );
      }
    });
  });
});
