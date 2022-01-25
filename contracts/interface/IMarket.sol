// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket {
    event CreateOrder(uint256 _orderID, address _NFTToken, uint256 _tokenID, address _owner, address _recvToken, uint256 _price);
    event CancelOrder(uint256 _orderID, address _NFTToken, uint256 _tokenID);
    event UpdateOrder(uint256 _orderID, address _NFTToken, uint256 _tokenID, address _recvToken,uint256 _price);
    event BuyCard(uint256 _orderID, address _NFTToken, uint256 _tokenID, address _owner, address _buyer, address _recvToke, uint256 _price, uint256 _fee);
    event SetFeeRate(uint256 _feeRate);
    event SetFeeTo(address _feeTo);

   function createOrder(address _NFTToken, uint256 _tokenID, address _recvToken, uint256 _price) external returns (uint256 _orderID);
   function cancelOrder(uint256 _orderID) external;
   function updateOrder(uint256 _orderID, address _recvToken, uint256 _price) external;
   function buyCard(uint256 _orderID) external payable;
   function setFeeRate(uint256 _feeRate) external;
   function setController(address _controller) external;


   function orders(uint256 _orderID) external view returns(address _NFTToken, uint256 tokenID, address _owner, address _recvToken, uint256 _price, uint256 _oStatus);
   function userOrderCount(address _user) external view returns(uint256 _userOrderCount);
   function userOrders(address _user, uint256 _index) external view returns(uint256 _orderID);
   function feeRate() external view returns(uint256 _feeRate);
}




