-include .env

build:; forge build

deploy-sepolia:
	forge script script/deployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

#to get a more advanced make file, go to Cyfrin's github to Foundry-Fund-Me