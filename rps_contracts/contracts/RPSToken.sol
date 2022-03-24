//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract RPSToken is ERC20, Ownable {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){
        
    }

    function mint(address account, uint256 amount) public onlyOwner() {
        _mint(account, amount);
    }
}