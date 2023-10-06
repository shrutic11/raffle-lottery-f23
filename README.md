# Raffle Lottery Smart Contract

This repository contains a Solidity smart contract for a raffle lottery implemented on the Ethereum blockchain. The contract utilizes Chainlink VRF (Verifiable Random Function) for secure and transparent randomization of lottery winners.

## Overview

The Raffle Lottery Smart Contract provides functionality for users to participate in a lottery by entering with a specific amount of Ether. The lottery runs for a defined interval, and after the interval, a winner is randomly selected from the pool of participants.

## Smart Contract Details

The smart contract is written in Solidity and implements various features including lottery state management, entrance fee, random winner selection, event logging, and more.

## Cloning the Repository

To clone this repository, use the following command:

```bash
git clone https://github.com/shrutic11/raffle-lottery-f23.git
cd raffle-lottery-f23
```

## Smart Contract Details

The smart contract is written in Solidity and implements the following main features:

1. **Lottery State Management**: The contract defines the lottery state, including OPEN, PICKING_WINNER, and CLOSED states.

2. **Entrance Fee**: Participants are required to pay a specific entrance fee in Ether to enter the lottery.

3. **Random Winner Selection**: The contract uses Chainlink VRF to select a random winner from the participants at the end of the lottery interval.

4. **Event Logging**: Various events are logged during different stages of the lottery, including participant entry, winner announcement, and the start of a new lottery.

5. **Fallback Function**: The contract includes a fallback function to handle ETH sent to the contract.

## How to Use

To participate in the lottery, users can call the `enterRaffle` function by sending the required Ether.

### Constructor

- **Parameters**:
  - `lotteryOpenInterval`: The time interval during which the lottery is open for participants.
  - `vrfCoordinator`: The address of the Chainlink VRF Coordinator contract.
  - `gasLane`: The gas lane for Chainlink VRF request.
  - `subscriptionId`: The Chainlink VRF subscription ID.
  - `callbackGasLimit`: The gas limit for the Chainlink VRF callback.

### Functions

- `enterRaffle`: Allows users to enter the lottery by paying the entrance fee.

- `checkUpkeep`: Checks if upkeep is needed for the lottery based on specific conditions.

- `performUpkeep`: Initiates the process to select a winner and distribute prizes.

- `fulfillRandomWords`: Handles the callback from Chainlink VRF and determines the lottery winner.

### Getters

- `getEntranceFee`: Returns the entrance fee required to enter the lottery.

- `getLotteryOpenInterval`: Returns the time interval during which the lottery is open.

- `getOwner`: Returns the owner's address who deployed the contract.

- `getLotteryStartTime`: Returns the start time of the current lottery.

- `getParticipants`: Returns an array of addresses representing the participants in the current lottery.

- `getLotteryState`: Returns the current state of the lottery.

## License

This project is licensed under the terms of the MIT license.

---

For more information and to access the smart contract code, visit the [GitHub repository](https://github.com/shrutic11/raffle-lottery-f23).