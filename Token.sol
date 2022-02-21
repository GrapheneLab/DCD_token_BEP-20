// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface IAntisnipe {
    function assureCanTransfer(
        address sender,
        address from,
        address to,
        uint256 amount,
        address owner
    ) external returns (bool response);
}

contract Token is ERC20, Ownable {
    IAntisnipe antisnipe;
    bool public antisnipeEnabled = true;
    uint256 constant TOTAL_SUPPLY = 1e26; // 500M tokens

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    function setAntisnipeAddress(address antisnipeAddress) external onlyOwner {
        require(address(antisnipe) == address(0));
        antisnipe = IAntisnipe(antisnipeAddress);
    }

    function setAntisnipeDisable() external onlyOwner {
        require(antisnipeEnabled);
        antisnipeEnabled = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (antisnipeEnabled)
            require(antisnipe.assureCanTransfer(msg.sender, from, to, amount, owner()));
        super._transfer(from, to, amount);
    }
}
