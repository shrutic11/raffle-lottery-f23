//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffleLottery} from "../../script/DeployRaffleLottery.s.sol";
import {RaffleLottery} from "../../src/RaffleLottery.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleLotteryTest is Test {
    /** State Variables */
    RaffleLottery raffleLottery;
    HelperConfig helperConfig;
    address public TEST_PLAYER = makeAddr("TEST_PLAYER");
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant ENTRANCE_FEE = 0.01 ether;
    uint256 public constant HIGHER_ENTRANCE_FEE = 0.05 ether;

    uint256 lotteryOpenInterval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;

    /** Events */
    event SomeoneDonated(address indexed funder, uint256 amount);
    event NewParticipant(address indexed participant);
    event WinnerAnnounced(address indexed lottery, address winner);
    event NewLotteryBegins(uint256);
    event RemainingBalanceTransferedToOwner(uint256);

    function setUp() external {
        DeployRaffleLottery deployRaffle = new DeployRaffleLottery();
        (raffleLottery, helperConfig) = deployRaffle.run();
        (
            lotteryOpenInterval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link
        ) = helperConfig.activeNetworkConfig();
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
    function testLotteryStateInitializesInOpenState() public view {
        assert(
            raffleLottery.getLotteryState() == RaffleLottery.LotteryState.OPEN
        );
    }

    function testLotteryStartTime() public {} //combined with lottery reset

    function testTheLotteryClosesAfterTheTimeInterval() public {} //after automation

    /////////////////////////
    // enterRaffleLottery  //
    /////////////////////////

    function testPlayerCannotEnterWithoutPayingEnoughEntranceFee() public {
        vm.prank(TEST_PLAYER);
        vm.expectRevert(
            RaffleLottery.RaffleLottery__InsufficientEntranceFee.selector
        );
        raffleLottery.enterRaffle();
    }

    function testPlayerCannotEnterWhenTheTimeIntervalHasPassed() public {
        vm.warp(block.timestamp + raffleLottery.getLotteryOpenInterval() + 1);
        vm.roll(block.number + 1);
        vm.expectRevert(RaffleLottery.RaffleLottery__LotteryClosed.selector);
        vm.prank(TEST_PLAYER);
        raffleLottery.enterRaffle{value: ENTRANCE_FEE}();
    }

    function testPlayerCannotEnterWhenRaffleIsPickingWinner() public {
        vm.prank(TEST_PLAYER);
        raffleLottery.enterRaffle{value: ENTRANCE_FEE}();
        vm.warp(block.timestamp + raffleLottery.getLotteryOpenInterval() + 1);
        vm.roll(block.number + 1);
        raffleLottery.performUpkeep("");

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
    /////////////////////////
    // checkUpKeep         //
    /////////////////////////
}
