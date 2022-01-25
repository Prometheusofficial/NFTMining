// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Manageable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address private _owner;
    mapping(address=>bool) public managers;

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }


     modifier onlyManager(){
        require(managers[_msgSender()], "NOT_MANAGER");
        _;
    }

    function addManager(address _manager) public onlyOwner {
        require(_manager != address(0), "ZERO_ADDRESS");
        managers[_manager] = true;
    }
  
    function delManager(address _manager) public onlyOwner {
        require(_manager != address(0), "ZERO_ADDRESS");
        managers[_manager] = false;
    }
    
}