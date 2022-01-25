// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRandoms {
    event SetCompose(address compose);
    event SetInterval(uint256 interval);

    struct RandomSeed {
        uint256 blockNumber;
        uint256 seed;
    }

    function getRandomSeedsLength() external view returns(uint256);

    function updateSeed(uint256 _seed) external returns(uint256);

    function generateRandoms(uint256 _seedIndex, uint256 _upBlock, uint256 _searchLength, uint256 _randomNum) external view  returns(uint256[] memory);

    function setCompose(address _compose) external;

    function setInterval(uint256 _interval) external;
}