#!/usr/bin/env bash

if [ -f .env.secrets ]
then
  export $(cat .env.secrets | xargs) 
else
    echo "Please set your .env.secrets file"
    exit 1
fi

if [ -f .env.common ]
then
  export $(cat .env.common | xargs) 
else
    echo "Please set your .env.common file"
    exit 1
fi

# Initialize variables
GAS_PRICE=""
PRIORITY_GAS_PRICE=""
CHAIN_ID=""
RPC_URL=""
WRAPPED_NATIVE_COIN=""
COIN_1=""
COIN_2=""
COIN_3=""
COIN_4=""

# Function to display usage
usage() {
    echo "Usage: $0 --gas-price <gas price> --priority-gas-price <priority gas price> --chain-id <chain id>"
    exit 1
}

# Function to set RPC URL based on chain ID
set_rpc_url() {
    case $1 in
        1) RPC_URL=$RPC_URL_ETHEREUM ;;
        10) RPC_URL=$RPC_URL_OPTIMISM ;;
        56) RPC_URL=$RPC_URL_BSC ;;
        137) RPC_URL=$RPC_URL_POLYGON ;;
        324) RPC_URL=$RPC_URL_ZKEVM ;;
        1101) RPC_URL=$RPC_URL_POLYGON_ZKEVM ;;
        8453) RPC_URL=$RPC_URL_BASE ;;
        42161) RPC_URL=$RPC_URL_ARBITRUM ;;
        42170) RPC_URL=$RPC_URL_ARBITRUM_NOVA ;;
        43114) RPC_URL=$RPC_URL_AVALANCHE_C ;;
        59144) RPC_URL=$RPC_URL_LINEA ;;
        7777777) RPC_URL=$RPC_URL_ZORA ;;
        534352) RPC_URL=$RPC_URL_SCROLL ;;
        5) RPC_URL=$RPC_URL_GOERLI ;;
        999) RPC_URL=$RPC_URL_ZORA_TESTNET ;;
        5001) RPC_URL=$RPC_URL_MANTLE_TESTNET ;;
        59140) RPC_URL=$RPC_URL_GOERLI_LINEA ;;
        80001) RPC_URL=$RPC_URL_MUMBAI ;;
        84531) RPC_URL=$RPC_URL_GOERLI_BASE ;;
        534353) RPC_URL=$RPC_URL_SCROLL_ALPHA ;;
        11155111) RPC_URL=$RPC_URL_SEPOLIA ;;
        2863311531) RPC_URL=$RPC_URL_ANCIENT8 ;;
        13472) RPC_URL=$RPC_URL_IMMUTABLE_TESTNET ;;
        *) echo "Unsupported chain id"; exit 1 ;;
    esac

    export RPC_URL
}

# Function to set the native value threshold to check paused state based on chain ID
set_native_value_threshold_for_pause() {
  case $1 in
      1) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ETH ;;
      10) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_OPTIMISM ;;
      56) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_BSC ;;
      137) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_POLYGON ;;
      324) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ZKSYNC ;;
      1101) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_POLYGON_ZKEVM ;;
      8453) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_BASE ;;
      42161) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ARBITRUM ;;
      42170) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ARBITRUM_NOVA ;;
      43114) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_AVALANCHE ;;
      59144) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_LINEA ;;
      7777777) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ZORA ;;
      534352) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_SCROLL ;;
      5) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_GOERLI ;;
      999) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ZORA_TESTNET ;;
      5001) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_MANTLE_TESTNET ;;
      59140) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_LINEA_TESTNET ;;
      80001) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_MUMBAI ;;
      84531) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_BASE_GOERLI ;;
      534353) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_SCROLL_ALPHA ;;
      11155111) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_SEPOLIA ;;
      2863311531) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_ANCIENT_8_TESTNET ;;
      13472) NATIVE_VALUE_TO_CHECK_PAUSED_STATE=$NATIVE_VALUE_TO_CHECK_PAUSED_STATE_IMMUTABLE_ZKEVM_TESTNET ;;
      *) echo "Unsupported chain id"; exit 1 ;;
  esac

  export NATIVE_VALUE_TO_CHECK_PAUSED_STATE
}

# Process arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --gas-price) GAS_PRICE=$(($2 * 1000000000)); shift ;;
        --priority-gas-price) PRIORITY_GAS_PRICE=$(($2 * 1000000000)); shift ;;
        --chain-id) CHAIN_ID=$2; shift ;;
        *) usage ;;
    esac
    shift
done

# Check if all parameters are set
if [ -z "$GAS_PRICE" ] || [ -z "$PRIORITY_GAS_PRICE" ] || [ -z "$CHAIN_ID" ]; then
    usage
fi

# Set the RPC URL based on chain ID
set_rpc_url $CHAIN_ID

# Set the native value threshold to check paused state based on chain ID
set_native_value_threshold_for_pause $CHAIN_ID

echo ""
echo "============= CONFIGURING TRANSFER VALIDATOR CONFIGURATION ============="

echo "Gas Price (wei): $GAS_PRICE"
echo "Priority Gas Price (wei): $PRIORITY_GAS_PRICE"
echo "Chain ID: $CHAIN_ID"
echo "RPC URL: $RPC_URL"
echo "EXPECTED_VALIDATOR_CONFIGURATION_ADDRESS: $EXPECTED_VALIDATOR_CONFIGURATION_ADDRESS"
echo "NATIVE_VALUE_TO_CHECK_PAUSED_STATE: $NATIVE_VALUE_TO_CHECK_PAUSED_STATE"
read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
  yes ) echo ok, we will proceed;;
  no ) echo exiting...;
    exit;;
  * ) echo invalid response;
    exit 1;;
esac

cast send \
  --private-key $DEPLOYER_KEY \
  --gas-price $GAS_PRICE \
  --priority-gas-price $PRIORITY_GAS_PRICE \
  --rpc-url $RPC_URL \
  $EXPECTED_VALIDATOR_CONFIGURATION_ADDRESS \
  "setNativeValueToCheckPauseState(uint256)" \
  $NATIVE_VALUE_TO_CHECK_PAUSED_STATE