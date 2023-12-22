// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/** Import Statements */
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {BookieToken, ERC20} from "./BookieToken.sol";
import {AutomationCompatibleInterface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {TimeLock} from "./TimeLock.sol";

/** Error Declarations */
error theBookie__WrongBook();
error theBookie__SummaryTooShort();
error theBookie__MintingFailed();
error theBookie__RatingMustBeBetween1And5Stars();

/** Contracts, Interfaces, Libraries */
/**
 * @title theBookie SmartContract
 * @author Samuel Dominguez
 * @notice
 */
contract TheBookie is Ownable, AutomationCompatibleInterface {
    ///////////////////////////////
    ////   Type Declarations  /////
    ///////////////////////////////
    BookieToken private immutable i_bookieToken;
    ///////////////////////////////
    ////    State Variables   /////
    ///////////////////////////////
    string public currentBook;
    string[] public previousBooks;
    string[] public votableBooks;

    mapping(string bookName => mapping(uint256 stars => uint256 addToThisStar))
        public bookStarReviews;
    mapping(string bookName => string[] summaries) public bookSummaries;

    ///////////////////////////////
    ////        Events        /////
    ///////////////////////////////
    event BookOfTheMonthChanged(string book);
    event SummarySubmittedAndUserRewarded(address user, uint256 amountOfTokens);
    event StarReviewSubmittedAndUserRewarded(address user, uint256 amount);

    ///////////////////////////////
    ////       Modifiers      /////
    ///////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////
    ////       Functions      ////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    constructor(
        address initialOwner,
        address _bookieToken
    ) Ownable(initialOwner) {
        i_bookieToken = BookieToken(_bookieToken);
    }

    /** bookOfTheMonth
     * @dev this function stores the current book of the month
     * @dev the book of the month changes when the Governor contract
     * completes a vote of proposed books and the Governor contract
     * will call this function and change the book
     */
    function BookOfTheMonth(string memory _book) public onlyOwner {
        previousBooks.push(currentBook);
        currentBook = _book;

        votableBooks = new string[](0);
        emit BookOfTheMonthChanged(_book);
    }

    /**
     * @dev this function allows a user to submit a summary for the current book
     * of the month
     * @dev after submitting a sumamry for the correct book, you will be rewarded with
     * minted theBookieToken - 3 tokens per sumamry
     */
    function Summary(
        string memory _book,
        string memory _summary
    ) public payable {
        if (
            keccak256(abi.encodePacked(_book)) !=
            keccak256(abi.encodePacked(currentBook))
        ) {
            revert theBookie__WrongBook();
        }

        bytes memory summaryBytes = bytes(_summary);
        if (summaryBytes.length < 100) {
            revert theBookie__SummaryTooShort();
        }

        // add the summary to the array of summaries for the sepcific book
        bookSummaries[_book].push(_summary);

        // reward the user for their summary with 3 theBookieToken's
        i_bookieToken.mint(msg.sender, 3);

        emit SummarySubmittedAndUserRewarded(msg.sender, 3);
    }

    /**
     * @dev this function allows a user to submit a star review for the current book of the month
     * @dev user is rewarded with one token for submitting a review
     * @param starRating is the amount of star out of 5 that the user rates the book
     */
    function SubmitStarReview(
        string memory _book,
        uint256 starRating
    ) public payable {
        if (
            keccak256(abi.encodePacked(_book)) !=
            keccak256(abi.encodePacked(currentBook))
        ) {
            revert theBookie__WrongBook();
        }

        if (starRating > 5 || starRating < 1) {
            revert theBookie__RatingMustBeBetween1And5Stars();
        }

        // add the star rating to the book
        bookStarReviews[_book][starRating] += 1;

        // reward the user with 1 theBookieToken
        i_bookieToken.mint(msg.sender, 1);

        emit StarReviewSubmittedAndUserRewarded(msg.sender, 1);
    }

    /**
     * @notice this function allows a member of the DAO to submit and add a book to the array of books
     * to be voted on for the next book of the month
     * @dev any book submission requires the user to burn 1 bookie Token to ensure they have stake in the DAO
     */
    function addBook(string memory _bookName) public payable {
        i_bookieToken.burn(msg.sender, 1);
        votableBooks.push(_bookName);
    }

    /**
     * @notice this function is created so that new users can receive a "welcome bonus" - giving them the ability
     * to have atleast, some small say in the voting process as an incentive to get them interested and engaged.
     * @param _to is the user calling the function to receive their initial bookieToken for joining so they can vote
     */
    function mintStartingTokenAllowance(address _to) public {
        i_bookieToken.mintStartingAllowance(_to);
    }
}
