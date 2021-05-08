// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../contracts/NFT.sol";

contract TestNFT {
    function test_mint_forSale_getPrice() public {
        NFT nft = new NFT();

        uint256 id =
            nft.mint(
                "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg"
            );
        uint256 price = 10000;
        nft.forSale(id, price);

        uint256 actual = nft.getPrice(id);
        uint256 expected = price;

        Assert.equal(actual, expected, "Price should be 10000");
    }
}
