// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketPlace is ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter noOfItems;
    Counters.Counter itemsSold;
    struct MarketItem {
        uint itemId;
        address nft;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        }
    mapping(uint => MarketItem) public idOfMarketItem  ;
    event ItemCreated(uint itemId, address nft, uint tokenId, address seller, uint price);
    uint listingprice = 10 ether;
    address payable operator;

    constructor()  payable {
        operator=payable(msg.sender);
    }

    function createitem(address nft,uint tokenId,uint price) public payable nonReentrant{
        require(price>0,"Price of NFT has to be atleat 1 wei");
        require(msg.value ==listingprice, "Pay listing price");
        noOfItems.increment();
        uint itemId = noOfItems.current();
        operator.transfer(msg.value);
        noOfItems.increment();
        idOfMarketItem[itemId]= MarketItem({
            itemId :itemId,
            nft:nft,
            tokenId:tokenId,
            seller : payable(msg.sender),
            owner : payable(address(0)),
            price :price
        });
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        emit ItemCreated(itemId, nft, tokenId, msg.sender, price);

        }
    function sellItem(address nft, uint itemid) public payable nonReentrant{
        uint itemPrice= idOfMarketItem[itemid].price;
        uint itemTokenId = idOfMarketItem[itemid].tokenId;
        require(msg.value == itemPrice, "Send the exact price of the nft");
        idOfMarketItem[itemid].seller.transfer(msg.value);
        IERC721(nft).transferFrom(address(this),msg.sender,itemTokenId);
        idOfMarketItem[itemid].owner = payable(msg.sender);
        itemsSold.increment();
    }

    function fetchItemList() public  view returns(MarketItem[] memory){
        uint unsoldItem = noOfItems.current() - itemsSold.current();
        MarketItem[] memory items = new MarketItem[](unsoldItem);
        uint currentIndex = 0;
        for (uint i; i<noOfItems.current(); i++){
            if(idOfMarketItem[i].owner == address(0)){
                uint currentid= idOfMarketItem[i].itemId;
                MarketItem storage currentItem = idOfMarketItem[currentid];
                items[currentid]= currentItem;
                currentIndex +=1;

            }
        }
        return items;

    }
    function mypurchasedItem() public  view returns(MarketItem[] memory){
        uint maxItem = noOfItems.current();
        MarketItem[] memory items = new MarketItem[](maxItem);
        uint currentIndex = 0;
        for (uint i; i<noOfItems.current(); i++){
            if(idOfMarketItem[i].owner == msg.sender){
                uint currentid= idOfMarketItem[i].itemId;
                MarketItem storage currentItem = idOfMarketItem[currentid];
                items[currentid]= currentItem;
                currentIndex +=1;

            }
        }
        return items;

    }
        

}