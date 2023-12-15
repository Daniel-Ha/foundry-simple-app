// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";

contract FundMeTest is Test {

    //initialize FundMe variable to test!
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;

    //setting up our variables to test
    function setUp() external{
        //using script to initialize FundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_VALUE);
    }

    //test to see if the MINIMUM_USD variable is equal to what we think it is (5e18)
    function testMinDollarIsFive() public{
        //assertEq: passes if they are equal! fails if not equal
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    //we are checking if the message sender is the owner!
    function testOwnerIsMsgSender() public{
        assertEq(fundMe.getOwner(), msg.sender);
    }

    //check to see that the conversion rate is correct:
    function testPriceConversion() public view{
        console.log(PriceConverter.getConversionRate(1, fundMe.getPriceFeedData()));
    }

    //check to see if the transaction fails if the transaction amount is not enough
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // "hey, the next line should revert!"
        //assert(this tx fails/reverts)
        fundMe.fund(); //not specifying a parameter means it sends 0 value
    }

    //check to see if the we correctly keep track of who funded what
    function testFundUpdatesFundedDataStructure() public {
        //create a fake new address to send all of your transactions using "prank"!!!!
        vm.prank(USER); //the next TX will be sent by USER
        fundMe.fund{value:SEND_VALUE}();

        //using the fake user to check if the dictionary updates correctly!
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }


    //check to see if the array of funders is correctly updating!
    function testAddsFunderToArrayOfFunders() public funded{

        //use fake user to see if array updates properly (or at least adds the first user)
        assertEq(USER, fundMe.getFunder(0));
    }

    //check to see that only the owner of the contract that withdraw funds
    function testOnlyOwnerCanWithdraw() public funded{
        //fund the project with a fake person first
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    //test withdrawing that actually works!
    function testWithdrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); //should have spent gas?: actually, during these tests, gas is not simulated. We need to tell solidity

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        //so why here does the balance evaluate to being equal to the sum of its parts? when some gas shoudl have been burnt?
        assertEq(endingOwnerBalance, startingFundMeBalance + startingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{

        //ARRANGE:
        uint160 numberOfFunders = 10;
        //send to 1 (instead of 0) for some reason that is kind of important!
        uint160 startingFunderIndex = 1;
        for(uint160 i=startingFunderIndex; i<numberOfFunders; i ++){
            //hoax does prank and deal at the same time!
            hoax(address(i), SEND_VALUE);
            console.log(address(i));
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT
        //different syntax for prank
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //ASSERT
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
    function testWithdrawFromMultipleFundersCheaper() public funded{

        //ARRANGE:
        uint160 numberOfFunders = 10;
        //send to 1 (instead of 0) for some reason that is kind of important!
        uint160 startingFunderIndex = 1;
        for(uint160 i=startingFunderIndex; i<numberOfFunders; i ++){
            //hoax does prank and deal at the same time!
            hoax(address(i), SEND_VALUE);
            console.log(address(i));
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT
        //different syntax for prank
        vm.startPrank(fundMe.getOwner());
        fundMe.cheapderWithdraw();
        vm.stopPrank();

        //ASSERT
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    //what can we do to work with addresses outside our system?:
    // 1. Unit:
    //  -Testing a specific part of our code
    // 2. Integration:
    //  -Testing how our code works with other parts of our code
    // 3. Forked
    // -Testing our code on a simulated real environment
    // 4. Staging
    // - Testing our code in a real environment that is not prod
}