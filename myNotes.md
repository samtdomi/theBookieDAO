Current Issues To Fix and Complete Project:

        1. governor contract only allows a vote to be cast for a uint256 and a proposal of a uint256, it cannot allow a vote to be cast for "nameof book" string
                - have to create a function in theBookie that allows a user to add a book to a list of all books to be voted on 
                - user has to burn 1 token to ensure they are an active member 

        2. WHICH FUCKING CONTRACT GETS CALLED WHEN TIMELOCK IS READY TO EXECUTE???????
                - is it the TimelockController "execute" function?
                - or is it the Governor 
        
        3. Finally learn and completely understand the role of the TimeLock contract and how to use it. finish it once and for all,
           figure out if it calls the execute function from its own contract or not, if so why, if not, then figure out the purpose 
           for it and how to use it and how it is used. AND MOVE ON 
        
        4. write unit test's 

        FINISH THE PROJECT 



Chain Of Commands:
        1. users propose books on the governor contract
        2. users vote for the books on the governor contract 
        3. when a proposal passes and a book is chosen, the governor contract proposes 
           to the TimeLock to execute the function call on theBookie to change the book
           of the month
        4. the TimeLock waits for a minimum delay of time to pass
        5. once, the minimum delay of time is passed, the TimeLock opens and allows anyone to 
           execute and the TimeLock then makes the function call 
           on theBookie.sol to change the book of the month
        6. theBookie.sol is now updated and the book of the month is changed and updated




/////////////////
/// TimeLock ////
/////////////////
 ** this has to be done AFTER deploying the timeLock contract and the BookieGovernor contract 
- setting up the roles assigned in the timelock contract so that the governor contract is the only address that can call the timelock
        1. proposer role (give to governor)
                - proposerRole = timeLock.PROPOSER_ROLE();
                - updateProposerRoleToGovernor = timeLock.grantRole(proposerRole, BookieGovernor.address);
        2. executor Role (give to no one, so anyone can execute) (FIX LATER TO CHAINLINK KEEPER)
                - executorRole = timeLock.EXECUTOR_ROLE();
                - updateExecutorRole = timeLock.grantRole(executorRole, "0x0");
        3. REVOKE YOU AS THE PROPOSER (you are given this role initially when deploying timeLock)
                - adminRole = timeLock.TIMELOCK_ADMIN_ROLE();
                - revokeAdminRole = timeLock.revokeRole(adminRole, msg.sender);

////////////////////////////////////////////////////////////////////
///////    CHAINLINK INTEGRATIONS - CHAINLINK Automation    ///////
///////////////////////////////////////////////////////////////////
- can you figre out how to use Chainlink Keepers as an integration into the DAO
by having it automatically execute when the "minDelay" of the "TimeLock.sol" is met?

- so instead of having "executors" be anyone (anyone currelty can execute the proposal once the minDelay time has passed) - the Chainlink Keepers will be the only executor!
        - the benefit is that the DAO is even more reliable and has an automation component to it
        making it super reliable that proposals will be executed exactly when the minDelay is satisfied

- for it to work, have to find a way to check when minDelay amount of time has passed, so that chainlink can 
have that satisifed and trigger the Automated call. 
        - find how the TimeLockController openzeppelin contrct checks to see whne minDelay time has passed, because it has 
        to have its own itnernal check becasue i am currently not sure when the TimeLockCOntroller "starts teh clock" 
                - when does it start recording the time to see when the minDelay has passed?
                - I am assuming the Governor makes an inital call and the TimeLockController records that and starts "the clock"
                and then continues to check if the minDelay has been met and then it executes what the Governor initially requested

    *** CHECKUPKEEP: [ timeLock contract ]
                the purpose is to return when it is time for Chainlink to be the "executor" of the TimeLock contract to call 
                the function on theBookie to update the new book of the month
        - where do we place the "checkUpkeep" function? returns (bool upkeepNeeded, bytes memory /* performData */)
                - the check will be if the minDelay has passed
                - the question is: when does block.timestamp get recorded as the starting time?? 
                        - when Governor first calls timeLock after a proposal passes?
                        - but what does the Governor call? and how is it recorded in the TimeLock?

   *** PERFORMUPKEEP: [ theBookie? ] 
                - the purpose of this function is to be called performUpkeep so taht Chainlink automation knows 
                  that this is tehfunction to be automatically called wehn "checkUpkeep" is true
                - the function "bookOfTheMonth" will be changed to "performUpkeep"

                - theBookie is going to have to inherit or import "checkUpkeep" from TimeLock 
                - the problem is finding a way to have the "checkUpkeep" on the TimeLock contract 
                trigger "performUpkeep" on a different contract theBookie. is it possible?

                (bool upkeepNeeded ,) = timeLock.checkUpkeep("");
                if (!upkeepNeeded) {
                        revert;
                }

    *** What is the purpose of the "TimeLock" ? 
        - to be the owner of theBookie contract so that it is the only contract that can execute the function call
        that will update and change the book of the month
        - to ensure a minimum amount of time passes after a vote is passed before implementing the change to theBookie

   *** PROBLEMS WITH INTEGRATION:
        1. performUpkeep and checkUpkeep need to be on the same contract, i tried to make checkUpkeep on the timelock and performupkeep of theBookie - but it is not compatible and solidity wont allow that - both functions have to be on hte same contract 
         - so, either i place the function to change the book of the month (performUpkeep) in the TimeLock contract or i get rid of the TimeLock contract all together and make the Chainlink keepers the owner of theBookie and have theBookie inherit the TimeLockController and give it all of the functionality of the TimeLock

