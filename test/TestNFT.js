const NFT = artifacts.require("NFT");

const URI =
  "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg";

contract("NFT", function (accounts) {
  it("Test buy with mint and forSale", () => {
    const account_one = accounts[0];
    const account_two = accounts[1];

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
