// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable private admin;

    mapping(uint256 => NFTItem) private items;

    struct NFTItem {
        uint256 id;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool sold;
    }

    event ItemSold(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address buyer,
        uint256 price
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = payable(msg.sender);
    }

    function buyItem(uint256 itemId) external payable {
        require(items[itemId].id > 0 && !items[itemId].sold, "Item not available");
        require(msg.value >= items[itemId].price, "Insufficient funds");

        items[itemId].sold = true;
        _itemsSold.increment();

        ERC721(items[itemId].nftContract).transferFrom(address(this), msg.sender, items[itemId].tokenId);
        items[itemId].seller.transfer(msg.value);

        emit ItemSold(itemId, items[itemId].nftContract, items[itemId].tokenId, msg.sender, items[itemId].price);
    }

    function withdrawBalance() external onlyAdmin {
        admin.transfer(address(this).balance);
    }

    function totalItems() external view returns (uint256) {
        return _itemIds.current();
    }

    function totalItemsSold() external view returns (uint256) {
        return _itemsSold.current();
    }
}