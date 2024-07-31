// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GiftShop {
    uint count = 1;
    struct Product{
        uint product_Id;
        string product_Title;
        uint price;
        string disc;
        address buyer;

    }

    Product[] public products;

    event createProduct(string product_title, uint product_Id);
    event buyProduct(uint product_Id, address buyer);
    
    function registerProduct(string memory _productTitle, string memory _disc,uint _price) public{
        require(_price > 0, "Price must be above zero");
        Product memory tempProduct;
        tempProduct.product_Title = _productTitle;
        tempProduct.disc = _disc;
        tempProduct.price = _price;
        tempProduct.product_Id = count;
        products.push(tempProduct);
        count++;
        emit createProduct(_productTitle, tempProduct.product_Id);

    }

    function buyProduct(uint _productId) public {
        require(product);
    }

    
}

