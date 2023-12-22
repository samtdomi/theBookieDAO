// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TimelockController} from "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";
import {AutomationCompatibleInterface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

error TimeLock__UpkeepNotNeeded();

contract TimeLock is AutomationCompatibleInterface, TimelockController {
    // minDelay is how long ou have to wait before executing
    // proposers is the list of addresses that can propose
    // executors is the list of addresses taht can execute
    // admin
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) TimelockController(minDelay, proposers, executors, msg.sender) {}

    function checkUpkeep(
        bytes memory /* checkData */
    ) public returns (bool upkeepNeeded, bytes memory /* performData */) {
        // check to see if minDelay has passed
        (, , , , , , bytes32 id) = getKeepersInformation();
        upkeepNeeded = isOperationReady(id);
        return (upkeepNeeded, "0x0");
    }

    /**
     *
     * @notice \The perform upkeep function will allow Chainlink Keepers to be the executor
     * of the timelock contract that
     */
    function performUpkeep(bytes calldata /* performData */) public {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            return TimeLock__UpkeepNotNeeded();
        }

        // get the data passed in by the governor when scheduling with the Timelock, the same data will be used for execution
        (
            address currentTarget,
            uint256 currentValue,
            bytes calldata currentData,
            bytes32 currentPedecessor,
            bytes32 currentSalt,
            uint256 currentDelay,
            bytes32 currentScheduleId
        ) = getKeepersInformation();

        // chainlink keepers will call the execute function from the TimelockController contract, which has the
        // target as theBookie and the specific function to complete the automatic execution of the proposal
        super.execute(
            currentTarget,
            currentValue,
            currentData,
            currentPedecessor,
            currentSalt
        );
    }
}
