// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "lib/openzeppelin-contracts/contracts/utils/Nonces.sol";

error YouHaveTokens();
error NotEnoughTokens();

contract BookieToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("BookieToken", "TBT") ERC20Permit("BookieToken") {}

    function mint(address _to, uint256 _amount) public {
        super._mint(_to, _amount);
    }

    function mintStartingAllowance(address _to) public {
        uint256 startingTokens = 2;
        if (balanceOf(_to) > 0) {
            revert YouHaveTokens();
        }

        super._mint(_to, startingTokens);
    }

    function burn(address _account, uint256 _amount) public {
        uint256 userBalance = balanceOf(_account);
        if (userBalance < 1) {
            revert NotEnoughTokens();
        }

        _burn(_account, _amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
