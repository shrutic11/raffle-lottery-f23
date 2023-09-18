//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {RaffleLottery} from "src/RaffleLottery.sol";
import {DeployRaffleLottery} from "./DeployRaffleLottery.s.sol";

contract Interactions_EnterRaffle is Script {
    function run() external {
        //to be replaced with a code line to fetch the most recently deployed smart cpntract
        //  DeployRafflesLottery deploy = new DeployRafflesLottery();
        // RafflesLottery mostRecentRafflesLottery = new RafflesLottery();
        //  mostRecentRafflesLottery = deploy.run();
        interactionsEnterRaffle(
            RaffleLottery(0x5FbDB2315678afecb367f032d93F642f64180aa3)
        );
    }

    function interactionsEnterRaffle(
        RaffleLottery mostRecentRafflesLottery
    ) public {
        uint256 ENTRANCE_FEE = 0.1 ether;
        // mostRecentRafflesLottery.enterRaffle{value: ENTRANCE_FEE}();
    }
}
