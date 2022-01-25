// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPromotion {
    event PromotedCard(address _owner, uint256 _godTokenId, uint256 _battleCardId, uint256 _battleTokenId, uint256 _unlockTime,uint256 _timestamp);
    event SetCoolDownTime(uint256 _coolDownTime);
    event SetCardConfig(address _cardConfig);
    event SetGodNFT(address _godNFT);
    event SetBattleNFT(address _battleNFT);

    struct PromotingRecord {
        uint256 lastTimestamp;
    }

    function promote(uint256 _tokenId, uint256 _battleCardId) external;
    
    function setCoolDownTime(uint256 _coolDownTime) external;
    function setCardConfig(address _cardConfig) external;
    function setGodNFT(address _godNFT) external;
    function setBattleNFT(address _battleNFT) external;

    function promotionRecords(uint256 _tokenId) external view returns(uint256);
    
}