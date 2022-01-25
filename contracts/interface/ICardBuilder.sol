// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBattleNFT.sol";

interface ICardBuilder {
    event SetCardConfig(address _cardConfig);

    function buildBattleNFTAttributes(
        uint256[] memory _randoms,
        IBattleNFT.CAttributes_S memory _tAttrs0, 
        IBattleNFT.CAttributes_S memory _tAttrs1) 
        external view returns(uint256[] memory basicAttrs, uint256[] memory skillIds, uint256[] memory battleAttrs) ;

    function setCardConfig(address _cardConfig) external;
}