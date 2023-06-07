#!/bin/bash

set -eu
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo $SCRIPT_DIR

NETWORK_NAME=osmo
CHAIN_NAME=OSMO 
NODE_NAME=osmo
VAL_TOKENS=10000000000000000uosmo
STAKE_TOKENS=1000000uosmo
VAL_ACCT=oval1
ENDPOINT=osmo.poolparty.stridenet.co
PORT_ID=26656

HERMES_OSMO_ACCT=osmorly
ICQ_OSMO_ACCT=osmoicq

TRUST_PERIOD="21600s"
UNBONDING_TIME="21600s"
BLOCK_TIME="5s"
MAX_DEPOSIT_PERIOD="3600s"
VOTING_PERIOD="3600s"
SIGNED_BLOCKS_WINDOW="30000"
MIN_SIGNED_PER_WINDOW="0.050000000000000000"
SLASH_FRACTION_DOWNTIME="0.001000000000000000"

OSMO_CMD="osmosisd"
STATE="/home/vishal/.osmosisd"


echo "Initializing osmo..."
rm -rf $STATE
mkdir $STATE
touch $STATE/keys.txt
$OSMO_CMD init VISH --chain-id $CHAIN_NAME --overwrite 2> /dev/null
echo "Initialized"
sed -i -E 's|"stake"|"uosmo"|g' "${STATE}/config/genesis.json"
configtoml="${STATE}/config/config.toml"
clienttoml="${STATE}/config/client.toml"

sed -i -E 's|"full"|"validator"|g' $configtoml
sed -i -E "s|chain-id = \"\"|chain-id = \"OSMO\"|g" $clienttoml
sed -i -E "s|keyring-backend = \"os\"|keyring-backend = \"test\"|g" $clienttoml
# Enable prometheus
sed -i -E "s|prometheus = false|prometheus = true|g" $configtoml
echo "sed done"
rm -rf $STATE/keyring-test/
rm -rf $STATE/config/gentx/
$OSMO_CMD keys add $VAL_ACCT --keyring-backend=test >> $STATE/keys.txt 2>&1
echo "added keys"
# get validator address
VAL_ADDR=$($OSMO_CMD keys show $VAL_ACCT --keyring-backend test -a) > /dev/null
echo "grabbed val addr"
# add money for this validator account
$OSMO_CMD add-genesis-account ${VAL_ADDR} $VAL_TOKENS
$OSMO_CMD gentx $VAL_ACCT $STAKE_TOKENS --chain-id $CHAIN_NAME --keyring-backend test # 2> /dev/null
echo "added genesis account"
# now we grab the relevant node id
OSMO_NODE_ID=$($OSMO_CMD tendermint show-node-id)@$ENDPOINT:$PORT_ID
echo "Node ID: $OSMO_NODE_ID"

# Configure an NGINX reverse proxy
# nginx_conf="${STATE}/nginx.conf"
# cp ${SCRIPT_DIR}/nginx.conf $nginx_conf
# sed -i -E "s|HOME_DIR|osmo|g" $nginx_conf
# sed -i -E "s|ENDPOINT|$ENDPOINT|g" $nginx_conf
# rm -f "${nginx_conf}-e"

# add Hermes and ICQ relayer accounts on Stride
$OSMO_CMD keys add $HERMES_OSMO_ACCT --keyring-backend=test >> $STATE/keys.txt 2>&1
$OSMO_CMD keys add $ICQ_OSMO_ACCT --keyring-backend=test >> $STATE/keys.txt 2>&1
HERMES_OSMO_ADDRESS=$($OSMO_CMD keys show $HERMES_OSMO_ACCT --keyring-backend test -a)
ICQ_OSMO_ADDRESS=$($OSMO_CMD keys show $ICQ_OSMO_ACCT --keyring-backend test -a)

# Give relayer account token balance
$OSMO_CMD add-genesis-account ${HERMES_OSMO_ADDRESS} $VAL_TOKENS
$OSMO_CMD add-genesis-account ${ICQ_OSMO_ADDRESS} $VAL_TOKENS

# process gentx txs
$OSMO_CMD collect-gentxs 2> /dev/null

# add small changes to config.toml
# use blind address (not loopback) to allow incoming connections from outside networks for local debugging
sed -i -E "s|127.0.0.1|0.0.0.0|g" $configtoml
sed -i -E "s|minimum-gas-prices = \"\"|minimum-gas-prices = \"0uosmo\"|g" "${STATE}/config/app.toml"
# allow CORS and API endpoints for block explorer
sed -i -E 's|enable = false|enable = true|g' "${STATE}/config/app.toml"
sed -i -E 's|unsafe-cors = false|unsafe-cors = true|g' "${STATE}/config/app.toml"
sed -i -E "s|timeout_commit = \"5s\"|timeout_commit = \"${BLOCK_TIME}\"|g" $configtoml
sed -i -E  "s|trust_period = \"168h0m0s\"|trust_period = \"${TRUST_PERIOD}\"|g" $configtoml
sed -i -E "s|seeds = .*|seeds = \"\"|g" $configtoml

OSMO_GENESIS_FILE_TMP="${STATE}/config/genesis.json"
jq '.app_state.staking.params.unbonding_time = $newVal' --arg newVal "$UNBONDING_TIME" $OSMO_GENESIS_FILE_TMP > json.tmp && mv json.tmp $OSMO_GENESIS_FILE_TMP
jq '.app_state.gov.deposit_params.max_deposit_period = $newVal' --arg newVal "$MAX_DEPOSIT_PERIOD" $OSMO_GENESIS_FILE_TMP > json.tmp && mv json.tmp $OSMO_GENESIS_FILE_TMP
jq '.app_state.gov.voting_params.voting_period = $newVal' --arg newVal "$VOTING_PERIOD" $OSMO_GENESIS_FILE_TMP > json.tmp && mv json.tmp $OSMO_GENESIS_FILE_TMP
jq '.app_state.slashing.params.signed_blocks_window = $newVal' --arg newVal "$SIGNED_BLOCKS_WINDOW" $OSMO_GENESIS_FILE_TMP > json.tmp && mv json.tmp $OSMO_GENESIS_FILE_TMP
jq '.app_state.slashing.params.min_signed_per_window = $newVal' --arg newVal "$MIN_SIGNED_PER_WINDOW" $OSMO_GENESIS_FILE_TMP > json.tmp && mv json.tmp $OSMO_GENESIS_FILE_TMP
jq '.app_state.slashing.params.slash_fraction_downtime = $newVal' --arg newVal "$SLASH_FRACTION_DOWNTIME" $OSMO_GENESIS_FILE_TMP > json.tmp && mv json.tmp $OSMO_GENESIS_FILE_TMP


## add the message types ICA should allow to the host chain
ALLOW_MESSAGES='\"/cosmos.bank.v1beta1.MsgSend\", \"/cosmos.bank.v1beta1.MsgMultiSend\", \"/cosmos.staking.v1beta1.MsgDelegate\", \"/cosmos.staking.v1beta1.MsgUndelegate\", \"/cosmos.staking.v1beta1.MsgRedeemTokensforShares\", \"/cosmos.staking.v1beta1.MsgTokenizeShares\", \"/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward\", \"/cosmos.distribution.v1beta1.MsgSetWithdrawAddress\", \"/ibc.applications.transfer.v1.MsgTransfer\"'
sed -i -E "s|\"allow_messages\": \[\]|\"allow_messages\": \[${ALLOW_MESSAGES}\]|g" "${STATE}/config/genesis.json"
