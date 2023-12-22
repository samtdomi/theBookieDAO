// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "lib/forge-std/src/Script.sol";
import {BookieGovernor} from "../src/BookieGovernor.sol";
import {BookieToken} from "../src/BookieToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {TheBookie} from "../src/TheBookie.sol";

contract DeployDAO is Script {
    /**  STATE VARIABLES  */
    BookieGovernor bookieGovernor;
    BookieToken bookieToken;
    TimeLock timeLock;
    TheBookie theBookie;

    function run()
        external
        returns (BookieGovernor, BookieToken, TimeLock, TheBookie)
    {
        // timeLock minDelay is 3 hours: 3600 is 1 hour -> 10800 is 3 hours
        uint256 minDelay = 10800;
        address[] memory proposers;
        address[] memory executors;

        // allow all of these transactions to be able to be signed and sent onchain
        vm.startBroadcast();

        /** Deploy BookieToken */
        bookieToken = new BookieToken();

        /** Deploy TheBookie */
        theBookie = new TheBookie(msg.sender, address(bookieToken));

        /** Deploy Timelock with empty proposers and executors */
        timeLock = new TimeLock(minDelay, proposers, executors);

        // Transfer Ownership to TimeLock
        theBookie.transferOwnership(address(timeLock));

        /** Deploy BookieGovernor */
        bookieGovernor = new BookieGovernor(bookieToken, timeLock);

        /** Set Up ADMIN ROLES of TmeLock */
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();
        timeLock.grantRole(proposerRole, address(bookieGovernor));
        timeLock.grantRole(executorRole, address(0));
        timeLock.revokeRole(adminRole, msg.sender);

        // /** Deploy TheBookie */
        // theBookie = new TheBookie(msg.sender, address(bookieToken));

        return (bookieGovernor, bookieToken, timeLock, theBookie);
    }
}
