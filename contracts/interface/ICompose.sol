// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICompose {

    event ComposedCard(address _owner, uint256 _tokenId0, uint256 _tokenId1, uint256 _newTokenId, uint256 _timestamp);

    event SetCardBuiler(address cardBuilder);
    event SetBattleNFT(address _battleNFT);

    function compose(uint256 _tokenId0, uint256 _tokenId1) external;

    function setCardBuilder(address _cardBuilder) external;
    function setBattleNFT(address _battleNFT) external;


}