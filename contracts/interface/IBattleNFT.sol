// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBattleNFT {
    event Mint(
        address _owner,
        uint256 _tokenId, 
        uint256 _nameIdx, 
        uint256 _campIdx, 
        uint256 _cardIdx, 
        uint256 _jobIdx, 
        uint256 _classLevel, 
        uint256 _attrIdx, 
        uint256 _generation,
        uint256[] skillIds,
        uint256[] battleAttrs);
    event SetBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] _values);
    event SetExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value);
    event AddExtendAttributes(uint256 _tokenId,uint256 _value);

    struct CAttributes_S {
        uint256 nameIdx;        //1
        uint256 campIdx;        //2 1001 Japanese_God
        uint256 cardIdx;        //3
        uint256 jobIdx;         //4
        uint256 classLevel;     //5
        uint256 attrIdx;        //6
        uint256 generation;     //7 init 1, can not set directly
        uint256[] skillIds;     //8
        uint256[] battleAttrs;  //9 0 hp, 1 atk, 2 spd, 3, tec, 4 def, 5 mov 
        uint256[] extendsAttrs;
    }

    function mint(address _to, uint256[] memory _basicAttrs, uint256[] memory _skillIds, uint256[] memory _battleAttrs) external;

    function safeMint(address _to, uint256[] memory _basicAttrs,uint256[] memory _skillIds,uint256[] memory _battleAttrs,bytes memory _data) external;

    function setBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] memory _values) external;

    function burn(uint256 _tokenId) external;

    function cAttributes(uint256 _tokenId) external view returns(CAttributes_S memory);

    function getExtendAttributesLength(uint256 _tokenId) external view  returns(uint256);

    function getExtendAttributesValuebyIndex(uint256 _tokenId, uint256 _index) external view returns(uint256);

    function setExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value) external;

    function addExtendAttributes(uint256 _tokenId,uint256 _value) external;

    function viewTokenID()  external view returns(uint256);
}