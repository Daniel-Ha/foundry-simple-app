// SPDX-License-Identifier: MIT

//1. deploy mocks when we are on a local anvil chain
// 2. keep track of contract address across different chains
// sepolia ETH/USD
// mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";


contract HelperConfig is Script{
    //if we are on a local anvil, we deploy mocks
    //otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }
    constructor(){
        //chain id for sepolia = 11155111
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }

        //mainnet chainid = 1
        else if (block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        //if the chain id is not sepolia!
        else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
    function getMainnetEthConfig() public pure returns (NetworkConfig memory){
        // price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }
    
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
        //if we have set the pricefeed already, just GET
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        //1. deploy the mocks
        //2. return the mock address

        //if you don't, CREATE
        vm.startBroadcast();
        //create mock pricefeed
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        //
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}