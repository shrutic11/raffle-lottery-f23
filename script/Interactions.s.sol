//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {RaffleLottery} from "src/RaffleLottery.sol";
import {DeployRaffleLottery} from "./DeployRaffleLottery.s.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }

    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, address vrfCoordinator, , , , ) = helperConfig.activeNetworkConfig();
        return createSubscription(address(vrfCoordinator));
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint64) {
        console.log("Creating new subscription on: ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Congratulations! Your new subscription id is: ", subId);
        console.log(
            "Please update the new subscription id in the HelperConfig.sol."
        );
        return subId;
    }
}

contract FundSubscription is Script {
    uint96 constant FUND_AMOUNT = 3 ether;

    function run() external {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            address vrfCoordinator,
            ,
            uint64 subId,
            ,
            address link
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, subId, link);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint64 subID,
        address link
    ) public {
        console.log("Funding subscription: ", subID);
        console.log("Using VRFCoordinator: ", vrfCoordinator);
        console.log("On chain id: ", block.chainid);
        if (block.chainid == 31337) {
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subID,
                FUND_AMOUNT
            );
        } else {
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subID)
            );
            vm.stopBroadcast();
        }
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentRaffleContract) public {
        HelperConfig helperConfig = new HelperConfig();
        (, address vrfCoordinator, , uint64 subId, , ) = helperConfig
            .activeNetworkConfig();
        addConsumer(mostRecentRaffleContract, vrfCoordinator, subId);
    }

    function addConsumer(
        address mostRecentRaffleContract,
        address vrfCoordinator,
        uint64 subId
    ) public {
        console.log("Adding RaffleLottery Contract:", mostRecentRaffleContract);
        console.log("subscription id: ", subId);

        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subId,
            mostRecentRaffleContract
        );
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentRaffleContract = DevOpsTools
            .get_most_recent_deployment("RaffleLottery", block.chainid);
        addConsumerUsingConfig(mostRecentRaffleContract);
    }
}
