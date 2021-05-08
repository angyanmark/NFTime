// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../contracts/NFT.sol";

contract TestNFT {
    function test_balanceOf() public {
        NFT nft = new NFT();

        uint256 actual = nft.balanceOf(address(this));
        uint256 expected = 0;

        Assert.equal(actual, expected, "Should not have any NFTs");
    }

    function test_mint_with_balanceOf() public {
        NFT nft = new NFT();

        uint256 id =
            nft.mint(
                "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg"
            );

        uint256 actual = nft.balanceOf(address(this));
        uint256 expected = 1;

        Assert.equal(actual, expected, "Should have one NFT");
    }

    function test_forSale_and_getPrice_with_mint() public {
        NFT nft = new NFT();

        uint256 id =
            nft.mint(
                "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg"
            );
        uint256 price = 10000;
        nft.forSale(id, price);

        uint256 actual = nft.getPrice(id);
        uint256 expected = price;

        Assert.equal(actual, expected, "Price is incorrect");
    }

    function test_ownerOf_with_mint() public {
        NFT nft = new NFT();

        uint256 id =
            nft.mint(
                "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg"
            );

        address actual = nft.ownerOf(id);
        address expected = address(this);

        Assert.equal(actual, expected, "Wrong owner");
    }

    function test_mint_getPrice_without_forSale() public {
        bool r;
        (r, ) = address(this).call(abi.encodePacked(this.mint_getPrice_fails.selector));
        Assert.isFalse(r, "NFT should not be for sale!");
    }

    function mint_getPrice_fails() public {
        NFT nft = new NFT();
        uint256 id =
            nft.mint(
                "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg"
            );
        nft.getPrice(id);
    }
}
