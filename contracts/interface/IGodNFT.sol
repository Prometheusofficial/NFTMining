// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGodNFT {
    event Mint(address _owner, uint256 _tokenID, uint256 _nameIdx, uint256 _campIdx, uint256 _godId, uint256 _rarityIdx, uint256 _skillID, uint256[] _canCreate);
    event SetBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] _values);
    event SetExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value);
    event AddExtendAttributes(uint256 _tokenId,uint256 _value);

    struct CAttributes_S {
        uint256 nameIdx; 
        uint256 campIdx; 
        uint256 godIdx;
        uint256 rarityIdx; 
        uint256 skillID;  
        uint256[] canCreate;
        uint256[] extendsAttrs;
    }

    function mint(
        address _to, 
        uint256 _tokenId, 
        uint256 _nameIdx,  
        uint256 _campIdx,
        uint256 _godIdx, 
        uint256 _rarityIdx, 
        uint256 _skillID, 
        uint256[] memory _canCreate) external;

    function safeMint(
        address _to,
        uint256 _tokenId, 
        uint256 _nameIdx,  
        uint256 _campIdx,
        uint256 _godIdx, 
        uint256 _rarityIdx, 
        uint256 _skillID, 
        uint256[] memory _canCreate, 
        bytes memory _data) external;

    function cAttributes(uint256 _tokenId) external view returns(CAttributes_S memory);

    function setBasicAttributes(uint256 _tokenId, uint8 _typeAttributes, uint256 _value, uint256[] memory _values) external;

    function getExtendAttributesLength(uint256 _tokenId) external view  returns(uint256);

    function getExtendAttributesValuebyIndex(uint256 _tokenId, uint256 _index) external view returns(uint256);

    function setExtendAttributes(uint256 _tokenId,uint256 _index,uint256 _value) external;

    function addExtendAttributes(uint256 _tokenId,uint256 _value) external;
}