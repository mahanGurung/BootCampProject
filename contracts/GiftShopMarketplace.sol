// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ProductNFT.sol";
import "./FractionalToken.sol";

contract GiftShopMarketplace is Ownable {
    struct Product {
        uint product_Id;
        string product_Title;
        uint price;
        string desc;
        uint amount;
        string category;
        string nftUrl;
        bool sold;
    }

    struct TransactionStruct {
        uint256 id;
        address owner;
        uint256 salePrice;
        string title;
        string category;
        string description;
        uint256 amount;
        string nftUrl;
        uint256 timestamp;
    }

  
    

    

    FractionalToken public erc20Token;
    ProductNFT public erc721Token;
    address public registrar;
    uint public productCount = 1;
    uint public totalTx = 0;
   

    Product[] public products;
    TransactionStruct[] transactions;
    mapping(address => TransactionStruct) private nftsOwned;

    

    event CreateProduct(string product_title, uint product_Id);
    event BuyProduct(uint product_Id, address buyer);
    event UpdateProductPrice(uint product_Id, uint newPrice);
    event Listed(uint256 indexed listingId, uint256 indexed tokenId, address seller, uint256 price);
    event Sold(uint256 indexed listingId, address buyer);
    event FractionalListed(uint256 indexed fractionalListingId, address indexed fractionalToken, address seller, uint256 amount, uint256 price);
    event ethTransfer(address indexed buyer, address indexed owner, uint256 amount, uint256 timestamp);

    constructor(address _erc721Token,address _erc20Token, address _registrar, address initialOwner) Ownable(initialOwner) {
        // nftContract = MyToken(_nftContract);
        erc20Token = FractionalToken(_erc20Token);
        erc721Token = ProductNFT(_erc721Token);
        registrar = _registrar;
    }

    modifier onlyRegistrar() {
        require(msg.sender == registrar, "Only the registrar can register products");
        _;
    }

    function uploadNft(uint nfttokenId, string memory nftUrl) public onlyRegistrar{
        erc721Token.safeMint(owner(), nfttokenId,nftUrl);
    }

    function setApprovalForAll() public onlyRegistrar {
        address erc20TokenAddress = erc20Token.getContractAddress();
        bool approved = true;

        erc721Token.setApprovalForAll(erc20TokenAddress, approved);
    }

    function changeOwnerShipOfNft(uint tokenId) public onlyOwner{
        require(address(this) != address(0), "forgot to input address");
        erc721Token.transfer(address(this), tokenId);
    }

    function initialize(uint tokenId,uint _amount,string memory nftUrl) public onlyRegistrar{
        uploadNft(tokenId, nftUrl);
        changeOwnerShipOfNft(tokenId);
        setApprovalForAll();
        
        address erc721TokenAddress = erc721Token.getContractAddress();

        erc20Token.initialize(erc721TokenAddress, _amount,tokenId);
    }



    function registerProduct(
        string memory _productTitle,
        string memory _desc,
        string memory _category,
        uint _price,
        uint _amount,
        string memory url
    ) public onlyRegistrar {
        require(_price > 0, "Price must be above zero");

        initialize( productCount,_amount, url);
        
        Product memory tempProduct = Product({
            product_Id: productCount,
            product_Title: _productTitle,
            price: _price,
            desc: _desc,
            amount: _amount,
            category: _category,
            nftUrl: url,
            sold: false
            
        });

        products.push(tempProduct);
        emit CreateProduct(_productTitle, tempProduct.product_Id);
        productCount++;
    }

    function tranferEth(address to, uint256 amount) public  payable {
        require(msg.value >= amount, "Not enough ether");
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Failed to send Ether");

        emit ethTransfer(msg.sender, to, amount, block.timestamp);
    }

    function buyFractionalToken(uint _productId, uint256 itemAmount) public payable {
        require(_productId > 0 && _productId < productCount, "Invalid product ID");
        Product storage product = products[_productId - 1];
        require(product.sold == false, "Product already sold");

        uint totalProPrice = product.price / product.amount;
        uint totalPrice = totalProPrice * itemAmount;
        

        // address tokenOwner = owner();
        require(msg.value >= totalPrice, "Not enough ether");


        tranferEth(owner(), totalPrice);


        erc20Token.BuyToken(address(this), msg.sender, itemAmount);    
        // emit BuyProduct(_productId, msg.sender);
    }


    function buyProduct(uint _productId,uint productAmount) public payable {
        Product storage product = products[_productId - 1];
        uint totalPrice = products[_productId - 1].price * productAmount;
        require(product.sold == false, "Product already sold");

        buyFractionalToken(_productId, productAmount);


        require(erc20Token.balanceOf(msg.sender) != 0, "You do not own the required fractional tokens");

        transactions.push(
            TransactionStruct(
                totalTx,
                msg.sender,
                totalPrice,
                products[_productId - 1].product_Title,
                products[_productId-1].category,
                products[_productId - 1].desc,
                productAmount,
                products[_productId - 1].nftUrl,
                block.timestamp
            ));
        

        nftsOwned[msg.sender] =
            TransactionStruct({
                id: totalTx,
                owner: msg.sender,
                salePrice: totalPrice,
                title: products[_productId - 1].product_Title,
                category: products[_productId-1].category,
                description: products[_productId - 1].desc,
                amount: productAmount,
                nftUrl: products[_productId - 1].nftUrl,
                timestamp: block.timestamp
            });

        uint256 oldAmount = product.amount;
        product.amount = oldAmount - productAmount;

        erc20Token.burn(msg.sender, productAmount);

        
        totalTx++;
        emit BuyProduct(_productId, msg.sender);

    }

    function updateProductPrice(uint _productId, uint _newPrice) public onlyRegistrar {
        require(_productId > 0 && _productId < productCount, "Invalid product ID");
        require(_newPrice > 0, "Price must be above zero");
        
        Product storage product = products[_productId - 1];
        product.price = _newPrice;

        emit UpdateProductPrice(_productId, _newPrice);
    }

    function getProduct(uint _productId) public view returns (Product memory) {
        require(_productId > 0 && _productId < productCount, "Invalid product ID");
        return products[_productId - 1];
    }

    function getAllProduct() public view returns (Product[] memory) {
        return products;
    }

    function getAllTransactions() public view returns (TransactionStruct[] memory){
        return transactions;
    }

    function getNftOfUsers(address _user) public view returns (TransactionStruct memory){
        return nftsOwned[_user];
    }

}




