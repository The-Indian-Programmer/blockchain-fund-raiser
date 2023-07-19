// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {TransferFund} from "../src/TransferFund.sol";

contract DeployTransferFund is Script {

    function run() external returns (TransferFund) {
        vm.startBroadcast();
        TransferFund transferFund = new TransferFund();
        vm.stopBroadcast();
        return transferFund;
    }
}