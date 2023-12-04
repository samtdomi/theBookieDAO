// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/** Import Statements */
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {GovernorToken, ERC20} from "./GovernorToken.sol";

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
contract theBookie is Ownable {
    ///////////////////////////////
    ////   Type Declarations  /////
    ///////////////////////////////
    GovernorToken governorToken;
    ///////////////////////////////
    ////    State Variables   /////
    ///////////////////////////////
    string public currentBook;
    string[] public books;

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

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev this function stores the current book of the month
     * @dev the book of the month changes when the Governor contract
     * completes a vote of proposed books and the Governor contract
     * will call this function and change the book
     */
    function bookOfTheMonth(string memory _book) public onlyOwner {
        currentBook = _book;
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
        governorToken.mint(msg.sender, 3);

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
        governorToken.mint(msg.sender, 1);

        emit StarReviewSubmittedAndUserRewarded(msg.sender, 1);
    }
}
