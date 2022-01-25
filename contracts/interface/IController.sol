// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IController {
    
    function addTradingNFT(address _nft) external;
    function delTradingNFT(address _nft) external;
    function isTradingAllowed(address _nft) external view returns(bool);
    
}