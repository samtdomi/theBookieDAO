
* theBookie will be a smart contract that has the attributes of the DAO Book Club:
    - store current book of the month 
    - allow users to submit book summaries of the book of the month
    - allow users to rate book of the month
    - stores previous books and their ratings and summaries
    - mints tokens for users:
            - 1 for a star rating review
            - 3 for a summary submission

1. theBookie smart contract will be 100% controlled by BookieGovernor
        - BookieGovernor allows for proposals of books 
        - controls voting period length
        - allows voting
        - executes the function on theBookie smart contract that will change and update the book of the month

2. Users can call and execute these functions on theBookie:
        - submit summary
        - submit star review 
        - get/view previous book summaries
        - get/view previous book reviews
        
2B. ONLY the BookieGovernor will be able to execute the function to update the book of the month

3. ERC20 tokens will be used for voting (mostly used model in web3)