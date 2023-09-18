//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract RaffleLottery {
    /** Errors */
    error RaffleLottery__InsufficientEntranceFee();
    error RaffleLottery__Fallback_CannotAcceptEth(string);
    error RaffleLottery__LotteryClosed();
    error RaffleLottery__PrizeTransferFailed();

    /** Enums */
    enum LotteryState {
        OPEN,
        PICKING_WINNER,
        CLOSED
    }

    /** State Variables */

    uint256 private constant ENTRANCE_FEE = 0.01 ether;
    uint256 private immutable i_lotteryOpenInterval;
    address private immutable i_owner;

    uint256 private s_lotteryNewStartTime;
    address[] private s_participants;
    LotteryState private s_lotteryState;

    //transfer donation to the deployer.. write a code

    /** Events */
    event SomeoneDonated(address indexed funder, uint256 amount);
    event NewParticipant(address indexed participant);
    event WinnerAnnounced(address indexed lottery, address winner);
    event NewLotteryBegins(uint256);
    event RemainingBalanceTransferedToOwner(uint256);

    /** Functions */

    //constructor
    constructor(uint256 _lotteryOpenInterval) {
        i_owner = msg.sender;
        i_lotteryOpenInterval = _lotteryOpenInterval;
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

    //call this function automatically when time is up (function should be accessible by automation, so should be wither external or public)
    function pickAWinnerAndResetTheLottery() public {
        address winner;
        if (block.timestamp == s_lotteryNewStartTime + i_lotteryOpenInterval)
            s_lotteryState = LotteryState.PICKING_WINNER;

        /* code to pick a random winner */

        /* tranferring prize money to the winner */
        uint256 prize = ENTRANCE_FEE * s_participants.length;
        (bool sendSuccess, ) = payable(winner).call{value: prize}("");
        if (!sendSuccess) {
            revert RaffleLottery__PrizeTransferFailed();
        }
        emit WinnerAnnounced(address(this), winner);

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
