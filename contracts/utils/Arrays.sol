// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library Arrays {

    function indexOf(uint256[] memory arrayA, uint256 item) internal pure returns(uint256, bool) {
        uint256 length = arrayA.length;
        for (uint256 i = 0; i < length; i++) {
            if (arrayA[i] == item) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function contains(uint256[] memory arrayA, uint256 item) internal pure returns(bool) {
        (, bool isIn) = indexOf(arrayA, item);
        return isIn;
    }

    function intersect(uint256[] memory arrayA, uint256[] memory arrayB) internal pure returns(uint256[] memory) {
        uint256 length = arrayA.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(arrayB, arrayA[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        uint256[] memory newArray = new uint256[](newLength);
        uint256 j = 0;
        for (uint256 i = 0; i < length; i++) {
            if (includeMap[i]) {
                newArray[j] = arrayA[i];
                j++;
            }
        }
        return newArray;
    }

    function nonIntersect(uint256[] memory arrayA, uint256[] memory arrayB) internal pure returns(uint256[] memory) {
        uint256[] memory interArray = intersect(arrayA, arrayB);
        
        uint256[] memory newArray = new uint256[](arrayA.length+arrayB.length-2*interArray.length);
        uint256 j = 0;
        for(uint256 i=0; i<arrayA.length; i++) {
            if(!contains(interArray, arrayA[i])){
                newArray[j]=arrayA[i];
                j++;
            }
        }
        for(uint256 i=0; i<arrayB.length; i++) {
            if(!contains(interArray, arrayB[i])){
                newArray[j]=arrayB[i];
                j++;
            }
        }
        return newArray;
    }
}