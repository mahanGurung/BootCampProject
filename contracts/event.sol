// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Transfer{

    string name = "Mahan Gurung";
    

    event ethTransfer(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event ethTransfer2(address indexed from, address indexed to, uint256 amount, uint256 timestamp);


    function transferEth1( uint price, uint amount,address payable  _to) external  payable {
        uint totalPrice = price * amount;
        require(msg.value >=totalPrice, "Not enought price");
        require(msg.value > 0, "Send some ETH");
       

        _to.transfer(msg.value);

    

        emit ethTransfer(msg.sender, _to, msg.value, block.timestamp);
    }

    function setName(string memory _name) public {
        name = _name;
    }

    function getName() public view  returns (string memory){
        return name;
    }

    // function tranferEth(address to, uint256 amount) public  payable {
       
    //     require(msg.value >= amount, "Not enough ether");
    //     (bool success, ) = payable(to).call{value: amount}("");
    //     require(success, "Failed to send Ether");

    //     emit ethTransfer2(msg.sender, to, msg.value, block.timestamp);
    // }

    function transferEth( uint price, uint amount,address payable  _to) external  payable {
        
        uint totalPrice = price * amount;
        uint amoutInEther = totalPrice * 1e18;
        require(msg.value >=amoutInEther, "Not enought price");
        require(msg.value > 0, "Send some ETH");
       

        _to.transfer(amoutInEther);

    

        emit ethTransfer(msg.sender, _to, amoutInEther, block.timestamp);
    }

    function getContractAddress() public view returns(address){
        return address(this);
    }
    
}