//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffleLottery} from "../../script/DeployRaffleLottery.s.sol";
import {RaffleLottery} from "../../src/RaffleLottery.sol";

contract RaffleLotteryTest is Test {
    /** State Variables */
    RaffleLottery raffleLottery;
    address TEST_PLAYER = makeAddr("TEST_PLAYER");
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant ENTRANCE_FEE = 0.01 ether;
    uint256 constant HIGHER_ENTRANCE_FEE = 0.05 ether;

    /** Events */
    event SomeoneDonated(address indexed funder, uint256 amount);
    event NewParticipant(address indexed participant);
    event WinnerAnnounced(address indexed lottery, address winner);
    event NewLotteryBegins(uint256);
    event RemainingBalanceTransferedToOwner(uint256);

    function setUp() external {
        DeployRaffleLottery deployRaffle = new DeployRaffleLottery();
        raffleLottery = deployRaffle.run();
        vm.deal(TEST_PLAYER, STARTING_BALANCE);
    }

    ////////////////////////////
    // State Variable Getters //
    ///////////////////////////

    function testGetEntranceFee() public {
        assertEq(raffleLottery.getEntranceFee(), ENTRANCE_FEE);
    }

    ////////////////////////////
    // Raffle Lottery States  //
    ///////////////////////////
    function testLotteryStateIsOpen() public view {
        assert(
            raffleLottery.getLotteryState() == RaffleLottery.LotteryState.OPEN
        );
    }

    function testLotteryStartTime() public {} //combined with lottery reset

    function testTheLotteryClosesAfterTheTimeInterval() public {} //after automation

    /////////////////////////
    // enterRaffleLottery  //
    /////////////////////////

    function testUserCannotEnterWithoutPayingEnoughEntranceFee() public {
        vm.prank(TEST_PLAYER);
        vm.expectRevert(
            RaffleLottery.RaffleLottery__InsufficientEntranceFee.selector
        );
        raffleLottery.enterRaffle();
    }

    function testUserCannotEnterWhenTheTimeIntervalHasPassed() public {
        vm.warp(block.timestamp + raffleLottery.getLotteryOpenInterval() + 1);
        vm.expectRevert(RaffleLottery.RaffleLottery__LotteryClosed.selector);
        vm.prank(TEST_PLAYER);
        raffleLottery.enterRaffle{value: ENTRANCE_FEE}();
    }

    function testPlayerCanEnterRaffleWithEntranceFee() public {
        vm.prank(TEST_PLAYER);
        vm.expectEmit(address(raffleLottery));
        emit NewParticipant(TEST_PLAYER);

        raffleLottery.enterRaffle{value: ENTRANCE_FEE}();

        assertEq(raffleLottery.getParticipants()[0], TEST_PLAYER);
    }

    function testPlayerCanEnterRaffleWithHigherEntranceFeeAndMakesDonation()
        public
    {
        vm.prank(TEST_PLAYER);
        vm.expectEmit(address(raffleLottery));
        emit SomeoneDonated(TEST_PLAYER, HIGHER_ENTRANCE_FEE - ENTRANCE_FEE);
        raffleLottery.enterRaffle{value: HIGHER_ENTRANCE_FEE}();
    }
}
