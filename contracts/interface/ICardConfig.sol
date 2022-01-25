
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICardConfig {
    event SetBattleCardIdToBasicAttributes(uint256 _battleCardId, uint256[] _basicAttrs);
    event DelBattleCardIdToBasicAttributes(uint256 _battleCardId);
    event SetBattleCardIdToBattleAttributes(uint256 _battleCardId, uint256[] _battleAttrs);
    event DelBattleCardIdToBattleAttributes(uint256 _battleCardId);
    event SetJobClassToBattleCardId(uint256 _jobIdx, uint256 _classLevel, uint256 _battleCardId);
    event DelJobClassToBattleCardId(uint256 _jobIdx, uint256 _classLevel);

    struct BasicAttribute {
        bool exist;
        uint256 nameIdx;
        uint256 campIdx;
        uint256 cardIdx;
        uint256 jobIdx;
        uint256 classLevel;
        uint256 attrIdx;
    }

    struct BattleAttribute {
        bool exist;
        uint256 hp;
        uint256 atk;
        uint256 spd;
        uint256 tec;
        uint256 def;
        uint256 mov;
    }

    struct BattleCardIdConfig {
        bool exist;
        uint256 battleCardId;
    }

    function setBattleCardIdToBasicAttributes(uint256 _battleCardId, uint256[] memory _basicAttrs) external;

    function battleCardIdToBasicAttributes(uint256 _battleCardId) external view returns(BasicAttribute memory);

    function delBattleCardIdToBasicAttributes(uint256 _battleCardId) external;

    function setBattleCardIdToBattleAttributes(uint256 _battleCardId, uint256[] memory _battleAttrs) external;

    function battleCardIdToBattleAttributes(uint256 _battleCardId) external view returns(BattleAttribute memory);

    function delBattleCardIdToBattleAttributes(uint256 _battleCardId) external;

    function setJobClassToBattleCardId(uint256 _jobIdx, uint256 _classLevel, uint256 _battleCardId) external;

    function jobClassToBattleCardId(uint256 _jobIdx, uint256 _classLevel) external view returns(BattleCardIdConfig memory);

    function delJobClassToBattleCardId(uint256 _jobIdx, uint256 _classLevel) external;

    function jobClassToBasicAttributes(uint256 _jobIdx, uint256 _classLevel) external view returns(BasicAttribute memory);

    function jobClassToNameAndCardId(uint256 _jobIdx, uint256 _classLevel) external view returns(uint256, uint256);

}