//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {RaffleLottery} from "src/RaffleLottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffleLottery is Script {
    function run() external returns (RaffleLottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 lotteryOpenInterval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        RaffleLottery rafflesLottery = new RaffleLottery(
            lotteryOpenInterval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
        return (rafflesLottery, helperConfig);
    }
}
