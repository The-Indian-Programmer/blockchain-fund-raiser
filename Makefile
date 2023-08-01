-include .env


build:; forge build


deploy-sepolia:
	# forge script script/DeployTransferFund.d.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_VERIFY_KEY

	0x98fe5a19d4cFed46a069Bb6a1FECC766E36cdc5D