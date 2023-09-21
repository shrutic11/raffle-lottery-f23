//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {RaffleLottery} from "src/RaffleLottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffleLottery is Script {
    function run() external returns (RaffleLottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 lotteryOpenInterval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.activeNetworkConfig();
        if (subscriptionId == 0) {
            // Create Subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator
            );
        }
        //Fund it
        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(vrfCoordinator, subscriptionId, link);

        vm.startBroadcast();
        RaffleLottery rafflesLottery = new RaffleLottery(
            lotteryOpenInterval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(rafflesLottery),
            vrfCoordinator,
            subscriptionId
        );
        return (rafflesLottery, helperConfig);
    }
}
