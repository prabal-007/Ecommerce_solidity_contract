//SPDX-License-Identifier: UNLICENSED

pragma solidity > 0.5.0 < 0.9.0;

contract Ecommerce{

    struct Product{
        string title;
        string desc;
        uint product_id;
        uint price;
        address payable seller;
        address buyer;
        bool delivered;
    }

    uint counter = 1;
    Product[] public products;
    address payable public manager;
    
    bool destroyed = false;

    modifier isNotDestroyed{
        require(!destroyed,"Contract does not exit anymore.");
        _;
    }


    constructor(){
        manager = payable(msg.sender);
    }

    event registered(uint product_id, string title, address seller);
    event bought(uint product_id, address buyer);
    event delivered(uint product_id ,bool delivered);

    function registerProducts(string memory _title, string memory _desc, uint _price) public isNotDestroyed{
        require(_price > 0,"Product price should be more than 0");
        Product memory temp_Product;
        temp_Product.title = _title;
        temp_Product.desc = _desc;
        temp_Product.price = _price * 10**18;
        temp_Product.seller = payable(msg.sender);
        temp_Product.product_id = counter;
        products.push(temp_Product);
        counter++;
        emit registered(temp_Product.product_id,_title,msg.sender);
    }

    function buy(uint product_id) public payable isNotDestroyed{
        require(msg.value == products[product_id-1].price,"Invalid price entered!");
        // require(products.length > 0,"Inventory is empty");
        require(msg.sender != products[product_id-1].seller,"You already own this product");
        products[product_id-1].buyer = msg.sender;

        emit bought(product_id,msg.sender);
    }

    function delivery(uint product_id) public isNotDestroyed{
        require(products[product_id-1].buyer == msg.sender,"ooops, only buyer can confirm the order delivery");
        products[product_id-1].delivered = true;
        products[product_id-1].seller.transfer(products[product_id-1].price);

        emit delivered(product_id, products[product_id-1].delivered);
    }

    // function destroy() public{
    //     require(msg.sender == manager,"Only manager can take this action!");
    //     selfdestruct(manager);
    // }

    function destroy() public isNotDestroyed{
        require(msg.sender == manager,"Only Administrator/manager can take this action!");
        manager.transfer(address(this).balance);
        destroyed = true;
    }

    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }

}
