// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interface/IBattleNFT.sol";
import "../interface/IGodNFT.sol";
import "../utils/Manageable.sol";


contract ConfigMining is Manageable{
    uint256  public totalGameID;
    
    // 1 Generation 6
    // 2 HP 8-0
    // 3 ATK 8-1
    // 4 SPD 8-2
    // 5 TEC 8-3
    // 6 DEF 8-4 
    // 7 SkillAmount 7 
    // 8 Skill 7
    /*struct CAttributes_S {
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
    }*/
    
    struct AStruct{
        uint256 attribute;
        uint256 vaule;
    }
    mapping(uint256 => AStruct[]) public miningAttributesList;
    mapping(uint256 => bool) public isSetGameID;
    
    event SetCheckList(uint256 _gameID,uint256[]  _Attributes,uint256[]  _vaules);
    event UpdateCheckList(uint256 _gaimID,uint256 _Attribute,uint256 _vaule);
    
    function setCheckList(uint256 _gameID,uint256[] memory _Attributes,uint256[] memory _vaules) public onlyManager{
        require(!isSetGameID[_gameID], "duplicate add");
        uint256 len = _Attributes.length;
        require(_vaules.length == len,"not equel length");
        totalGameID += 1;
        for(uint256 i=0 ; i<len; i++){
            miningAttributesList[_gameID].push(AStruct({
                attribute:_Attributes[i],
                vaule:_vaules[i]
            }));
        }
        
        isSetGameID[_gameID] = true;

        emit SetCheckList(_gameID,_Attributes,_vaules);
        
    }
    
    function updateCheckList(uint256 _gameID,uint256 _Attribute,uint256 _vaule) public onlyManager{
        require(isSetGameID[_gameID],"not set this _gameID");
        uint256 len = miningAttributesList[_gameID].length;
        AStruct memory ams = AStruct({
            attribute:_Attribute,
                vaule:_vaule
        });
        
        for(uint256 i=0 ; i<len; i++){
            if(miningAttributesList[_gameID][i].attribute == _Attribute){
                miningAttributesList[_gameID][i] = ams;
                break;
            }
        }
        emit UpdateCheckList(_gameID,_Attribute,_vaule);
    }
    
    function isValidGameID(uint256 _gaimID) public view returns(bool){
        return isSetGameID[_gaimID];
    }
    
    function getCheckListLength(uint256 _gaimID) public view returns(uint256){
        return miningAttributesList[_gaimID].length;
    }
    
    function getAttributesVaule(uint256 _gaimID,uint256 _index) public view returns(uint256 _Attribute,uint256 _vaule){
        _Attribute = miningAttributesList[_gaimID][_index].attribute;
        _vaule = miningAttributesList[_gaimID][_index].vaule;
    }
    
}