// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../contracts/NFT.sol";

contract TestNFT {
    NFT nft = new NFT();

    string constant URI =
        "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg";

    function test_balanceOf() public {
        uint256 actual = nft.balanceOf(address(this));
        uint256 expected = 0;

        Assert.equal(actual, expected, "Should not have any NFTs");
    }

    function test_mint_with_balanceOf() public {
        nft.mint(URI);

        uint256 actual = nft.balanceOf(address(this));
        uint256 expected = 1;

        Assert.equal(actual, expected, "Should have one NFT");
    }

    function test_balanceOf_null_address() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.balanceOf_nulladdress_fails.selector)
        );
        Assert.isFalse(r, "Shouldm't return balance of null address!");
    }

    function test_forSale_and_getPrice_with_mint() public {
        uint256 id = nft.mint(URI);
        uint256 price = 10000;
        nft.forSale(id, price);

        uint256 actual = nft.getPrice(id);
        uint256 expected = price;

        Assert.equal(actual, expected, "Price is incorrect");
    }

    function test_ownerOf_with_mint() public {
        uint256 id = nft.mint(URI);

        address actual = nft.ownerOf(id);
        address expected = address(this);

        Assert.equal(actual, expected, "Wrong owner");
    }

    function test_mint_getPrice_without_forSale() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.mint_getPrice_fails.selector)
        );
        Assert.isFalse(r, "NFT should not be for sale!");
    }

    /* Helpers */

    function balanceOf_null_address_fails() public view {
        nft.balanceOf(address(0));
    }

    function mint_getPrice_fails() public {
        uint256 id = nft.mint(URI);
        nft.getPrice(id);
    }
}
