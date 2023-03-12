// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// 0x5CcBbbc0448d3903Aa9292634F197556f6AC953B
contract CollieCoin is ERC20, Ownable {
    constructor() ERC20("CollieCoin", "CC") {
        mint(msg.sender, 2500 * 10 ** 18);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}