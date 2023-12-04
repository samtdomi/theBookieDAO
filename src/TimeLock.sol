// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TimelockController} from "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    // minDelay is how long ou have to wait before executing
    // proposers is the list of addresses that can propose
    // executors is the list of addresses taht can execute
    // admin
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) TimelockController(minDelay, proposers, executors, msg.sender) {}
}
