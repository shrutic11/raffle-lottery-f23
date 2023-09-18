//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {RaffleLottery} from "src/RaffleLottery.sol";

contract DeployRaffleLottery is Script {
    function run() external returns (RaffleLottery) {
        vm.startBroadcast();
        RaffleLottery rafflesLottery = new RaffleLottery(24 hours);
        vm.stopBroadcast();
        return rafflesLottery;
    }
}
