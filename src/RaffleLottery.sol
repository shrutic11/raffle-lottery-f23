//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {console} from "forge-std/console.sol";

contract RaffleLottery is VRFConsumerBaseV2 {
    /** Errors */
    error RaffleLottery__InsufficientEntranceFee();
    error RaffleLottery__Fallback_CannotAcceptEth(string);
    error RaffleLottery__LotteryClosed();
    error RaffleLottery__PrizeTransferFailed();
    error RaffleLottery__UpKeepNotNeeded(uint256, uint256, LotteryState);

    /** Enums */
    enum LotteryState {
        OPEN,
        PICKING_WINNER,
        CLOSED
    }

    /** State Variables */

    uint256 private constant ENTRANCE_FEE = 0.01 ether;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_OF_WORDS = 1;

    uint256 private immutable i_lotteryOpenInterval;
    address private immutable i_owner;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lotteryNewStartTime;
    address[] private s_participants;
    LotteryState private s_lotteryState;
    address private s_recentWinner;

    /** Events */
    event SomeoneDonated(address indexed funder, uint256 amount);
    event NewParticipant(address indexed participant);
    event WinnerAnnounced(address indexed lottery, address winner);
    event NewLotteryBegins(uint256);
    event RemainingBalanceTransferedToOwner(uint256);

    /** Functions */

    //constructor
    constructor(
        uint256 lotteryOpenInterval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_owner = msg.sender;
        i_lotteryOpenInterval = lotteryOpenInterval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lotteryState = LotteryState.OPEN;
        s_lotteryNewStartTime = block.timestamp;
    }

    //external
    fallback() external {
        revert RaffleLottery__Fallback_CannotAcceptEth(
            "You have reached the fallback. To participate in the ongoing lottery, participate via enterRaffles()"
        );
    }

    //public
    function enterRaffle() public payable {
        if (
            block.timestamp - s_lotteryNewStartTime >= i_lotteryOpenInterval ||
            (s_lotteryState != LotteryState.OPEN)
        ) revert RaffleLottery__LotteryClosed();

        if (msg.value < ENTRANCE_FEE) {
            revert RaffleLottery__InsufficientEntranceFee();
        } else if (msg.value > ENTRANCE_FEE) {
            uint256 donation = msg.value - ENTRANCE_FEE;
            emit SomeoneDonated(msg.sender, donation);
        }
        s_participants.push(msg.sender);
        emit NewParticipant(msg.sender);
    }

    /**
     * @dev This function calls the chainlink automation node to see if it's time to perform upkeep.
     * The following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The raffle is in OPEN state.
     * 3. The contract has ETH.
     * 4. (Implicit)The subscription is funded with enough TEST LINKS.
     */

    function checkUpkeep(
        bytes memory /*check data*/
    ) public view returns (bool upKeepNeeded, bytes memory) {
        bool timeHasPassed = block.timestamp - s_lotteryNewStartTime >=
            i_lotteryOpenInterval;
        bool isOpen = (s_lotteryState == RaffleLottery.LotteryState.OPEN);
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_participants.length > 0;
        upKeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* perform data */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert RaffleLottery__UpKeepNotNeeded(
                address(this).balance,
                s_participants.length,
                s_lotteryState
            );
        }
        pickAWinnerAndResetTheLottery();
    }

    function pickAWinnerAndResetTheLottery() public {
        /* Change the lottery state to PICKING WINNER */
        s_lotteryState = LotteryState.PICKING_WINNER;

        /* Picking a random winner */
        uint256 s_requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gas lane
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_OF_WORDS
        );

        /* tranferring prize money to the winner */
        uint256 prize = ENTRANCE_FEE * s_participants.length;
        (bool sendSuccess, ) = payable(s_recentWinner).call{value: prize}("");
        if (!sendSuccess) {
            revert RaffleLottery__PrizeTransferFailed();
        }
        emit WinnerAnnounced(address(this), s_recentWinner);

        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(i_owner).transfer(balance);
            emit RemainingBalanceTransferedToOwner(balance);
        }

        //Reset Lottery
        s_participants = new address[](0);
        s_lotteryNewStartTime = block.timestamp;
        s_lotteryState = LotteryState.OPEN;
        emit NewLotteryBegins(block.timestamp);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_participants.length;
        s_recentWinner = s_participants[winnerIndex];
    }

    //** Getters and Setters */

    function getEntranceFee() public pure returns (uint256) {
        return ENTRANCE_FEE;
    }

    function getLotteryOpenInterval() public view returns (uint256) {
        return i_lotteryOpenInterval;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getLotteryStartTime() public view returns (uint256) {
        return s_lotteryNewStartTime;
    }

    function getParticipants() public view returns (address[] memory) {
        return s_participants;
    }

    function getLotteryState() public view returns (LotteryState) {
        return s_lotteryState;
    }
}
