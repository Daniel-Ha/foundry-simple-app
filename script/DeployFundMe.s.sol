// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//using library from Forge
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

//you need a deploy script to deploy!
contract DeployFundMe is Script{

    //function "run" is used to 
    function run() external returns (FundMe){
        
        //before startBroadcast -> not a real tx
        HelperConfig helperConfig = new HelperConfig();
        //use helper config to determine the right pricefeed address by finding the active network you are on!
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        //broadcast the code between start and stopBroadcast to the chain!
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}