// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "../contracts/NFT.sol";

contract TestNFT {
    NFT nft;

    string constant URI =
        "https://pbs.twimg.com/profile_images/1375929798296412160/zWcu5LX8.jpg";

    function beforeEach() public {
        nft = new NFT();
    }

    function test_balanceOf() public {
        uint256 actual = nft.balanceOf(address(this));
        uint256 expected = 0;

        Assert.equal(actual, expected, "Should not have any NFTs!");
    }

    function test_balanceOf_on_zero_address() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.balanceOf_zero_address_fails.selector)
        );
        Assert.isFalse(r, "Should throw on zero address!");
    }

    function test_mint_with_balanceOf() public {
        nft.mint(URI);

        uint256 actual = nft.balanceOf(address(this));
        uint256 expected = 1;

        Assert.equal(actual, expected, "Should have one NFT!");
    }

    function test_forSale_on_zero() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.forSale_zero_fails.selector)
        );
        Assert.isFalse(r, "Should throw on zero price!");
    }

    function test_getPrice_on_not_for_sale() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.getPrice_not_for_sale_fails.selector)
        );
        Assert.isFalse(r, "Should throw on not for sale!");
    }

    function test_forSale_and_getPrice_with_mint() public {
        uint256 id = nft.mint(URI);
        uint256 price = 10000;
        nft.forSale(id, price);

        uint256 actual = nft.getPrice(id);
        uint256 expected = price;

        Assert.equal(actual, expected, "Price is incorrect!");
    }

    function test_ownerOf_on_invalid_NFT() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.ownerOf_invalid_NFT_fails.selector)
        );
        Assert.isFalse(r, "Should throw on invalid NFT!");
    }

    function test_ownerOf_with_mint() public {
        uint256 id = nft.mint(URI);

        address actual = nft.ownerOf(id);
        address expected = address(this);

        Assert.equal(actual, expected, "Wrong owner!");
    }

    function test_notForSale_on_already_notForSale() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(
                this.notForSale_on_already_notForSale_fails.selector
            )
        );
        Assert.isFalse(r, "Should throw on not for sale NFT!");
    }

    function test_forSale_notForSale_getPrice() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.forSale_notForSale_getPrice_fails.selector)
        );
        Assert.isFalse(r, "NFT should not be for sale!");
    }

    function test_mint_burn_balanceOf() public {
        uint256 id1 = nft.mint(URI);
        uint256 balance = nft.balanceOf(address(this));
        Assert.equal(balance, 1, "Balance should be 1!");

        uint256 id2 = nft.mint(URI);
        balance = nft.balanceOf(address(this));
        Assert.equal(balance, 2, "Balance should be 2!");

        nft.burn(id1);
        balance = nft.balanceOf(address(this));
        Assert.equal(balance, 1, "Balance should be 1!");

        nft.burn(id2);
        balance = nft.balanceOf(address(this));
        Assert.equal(balance, 0, "Balance should be 0!");
    }

    function test_mint_forSale_burn_getPrice() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.mint_forSale_burn_getPrice_fails.selector)
        );
        Assert.isFalse(r, "NFT should not exist!");
    }

    function test_getApproved_with_mint() public {
        uint256 id = nft.mint(URI);

        address actual = nft.getApproved(id);
        address expected = address(0);

        Assert.equal(actual, expected, "No one should be approved!");
    }

    function test_getApproved_on_invalid_NFT() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.getApproved_on_invalid_NFT_fails.selector)
        );
        Assert.isFalse(r, "Should throw on invalid NFT!");
    }

    function test_approve_on_owner() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.approve_on_owner_fails.selector)
        );
        Assert.isFalse(r, "Should throw on owner!");
    }

    function test_approve_on_invalid_NFT() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.approve_on_invalid_NFT_fails.selector)
        );
        Assert.isFalse(r, "Should throw on invalid NFT!");
    }

    function test_buy_on_not_for_sale() public {
        bool r;
        (r, ) = address(this).call(
            abi.encodePacked(this.buy_on_not_for_sale_fails.selector)
        );
        Assert.isFalse(r, "Should throw on not for sale NFT!");
    }

    /* Helpers, throwing error */

    function balanceOf_zero_address_fails() public view {
        nft.balanceOf(address(0));
    }

    function forSale_zero_fails() public {
        uint256 id = nft.mint(URI);
        nft.forSale(id, 0);
    }

    function getPrice_not_for_sale_fails() public {
        uint256 id = nft.mint(URI);
        nft.getPrice(id);
    }

    function ownerOf_invalid_NFT_fails() public {
        nft.ownerOf(10);
    }

    function notForSale_on_already_notForSale_fails() public {
        uint256 id = nft.mint(URI);
        nft.notForSale(id);
    }

    function forSale_notForSale_getPrice_fails() public {
        uint256 id = nft.mint(URI);
        nft.forSale(id, 10000);
        nft.notForSale(id);
        nft.getPrice(id);
    }

    function mint_forSale_burn_getPrice_fails() public {
        uint256 id = nft.mint(URI);
        nft.forSale(id, 10000);
        nft.burn(id);
        nft.getPrice(id);
    }

    function getApproved_on_invalid_NFT_fails() public {
        nft.getApproved(10);
    }

    function approve_on_owner_fails() public {
        uint256 id = nft.mint(URI);
        nft.approve(address(this), id);
    }

    function approve_on_invalid_NFT_fails() public {
        nft.approve(address(this), 10);
    }

    function buy_on_not_for_sale_fails() public {
        uint256 id = nft.mint(URI);
        nft.buy(id);
    }
}
