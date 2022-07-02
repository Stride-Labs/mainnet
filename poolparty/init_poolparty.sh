#!/bin/sh
set -e
clear 

SCRIPT_VERSION="v0.0.3"

# you can always install this script with
# curl -L install.poolparty.stridelabs.co | sh

PURPLE='\033[0;35m'
BOLD="\033[1m"
BLUE='\033[1;34m'
ITALIC="\033[3m"
NC="\033[0m"

STRIDE_COMMIT_HASH=8c168c22cf03e581e77ac9e5973fbfb61cebf147
GENESIS_URL=https://bafkreibhpnsdis6suq4vtdgr6limdbguiwegb6qutswdjva57fvirqf36e.ipfs.dweb.link/
PERSISTENT_PEER_ID="9f12a6a255d6c42bbe97c5be9d4968defd9c989c@stride-node1.internal.stridenet.co:26656"

printf "\n\n${BOLD}Welcome to the setup script for Stride's Testnet, ${PURPLE}PoolParty${NC}!\n\n"
printf "This script will guide you through setting up your very own Stride node locally.\n"
printf "You're currently running $BOLD$SCRIPT_VERSION$NC of the setup script.\n\n"

printf "First, we need to give your node a nickname. "

node_name_prompt="What would you like to call it? "
while true; do
    read -p "$(echo $PURPLE"$node_name_prompt"$NC)" NODE_NAME
    if [ -z "$NODE_NAME" ] || ! [[ "$NODE_NAME" =~ ^[A-Za-z0-9-]*$ ]]; then
        printf '\nNode names can only container letters, numbers, and hyphens.\n'
        node_name_prompt="Please enter a new name. "
    else
        break
    fi
done

TESTNET="internal"
INSTALL_FOLDER="$HOME/.stride/$TESTNET"
STRIDE_FOLDER="$HOME/.stride"

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

printf "\nGreat, now we'll download the latest version of Stride.\n"
printf "Stride will keep track of blockchain state in ${BOLD}$STRIDE_FOLDER${NC}\n\n"

if [ -d $STRIDE_FOLDER ] 
then
    printf "${BOLD}Looks like you already have Stride installed.${NC}\n"
    printf "Proceed carefully, because you won't be able to recover your data if you overwrite it.\n\n"
    pstr="Do you want to overwrite your existing $TESTNET installation and proceed? [y/n] "
    while true; do
        read -p "$(echo $PURPLE"$pstr"$NC)" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.\n";;
        esac
    done
fi
printf $BLINE

rm -rf $STRIDE_FOLDER > /dev/null 2>&1
rm -f launch_testnet.sh > /dev/null 2>&1

mkdir -p $INSTALL_FOLDER
cd $INSTALL_FOLDER

echo "\nFetching Stride's code...\n"
git clone https://github.com/Stride-Labs/stride.git > /dev/null 2>&1
cd $INSTALL_FOLDER/stride 
git checkout $STRIDE_COMMIT_HASH > /dev/null 2>&1

# pick install location
DEFAULT_BINARY="$HOME/go/bin"
rstr="Where do you want to install your stride binary? [default: $DEFAULT_BINARY] "
read -p "$(echo Almost there\! $PURPLE"$rstr"$NC)" BINARY_LOCATION
if [ -z "$BINARY_LOCATION" ]; then
    BINARY_LOCATION=$DEFAULT_BINARY
fi
printf "\n"
mkdir -p $BINARY_LOCATION
sh $INSTALL_FOLDER/stride/scripts-local/build.sh -s $BINARY_LOCATION
printf "\n"

printf $BLINE

BINARY=$BINARY_LOCATION/strided
printf "\nLast step, we need to setup your genesis state to match PoolParty...\n"

$BINARY init $NODE_NAME --home $STRIDE_FOLDER --chain-id STRIDE --overwrite > /dev/null 2>&1

# Now pull the genesis file
curl $GENESIS_URL -o $STRIDE_FOLDER/config/genesis.json > /dev/null 2>&1

# # add persistent peer
config_path="$STRIDE_FOLDER/config/config.toml"
app_path="$STRIDE_FOLDER/config/app.toml"
sed -i -E "s|persistent_peers = \".*\"|persistent_peers = \"$PERSISTENT_PEER_ID\"|g" $config_path

# fetch state sync params
fetched_state="$(curl -s https://stride-node3.$TESTNET.stridenet.co:445/commit | jq "{height: .result.signed_header.header.height, hash: .result.signed_header.commit.block_id.hash}")"
height="$(echo $fetched_state | jq -r '.height')"
hash="$(echo $fetched_state | jq -r '.hash')"
sed -i -E "s|enable = false|enable = true|g" $app_path
sed -i -E "s|trust_height = 0|trust_height = $height|g" $app_path
sed -i -E "s|trust_hash = \"\"|trust_hash = \"$hash\"|g" $app_path
sed -i -E "s|trust_period = \"168h0m0s\"|trust_period = \"3600s\"|g" $app_path
statesync_rpc="stride-node2.$TESTNET.stridenet.co:26657,stride-node3.$TESTNET.stridenet.co:26657"
sed -i -E "s|rpc_servers = \"\"|rpc_servers = \"$statesync_rpc\"|g" $app_path

fstr="$BINARY start --home $STRIDE_FOLDER"

launch_file=$INSTALL_FOLDER/launch_poolparty.sh
rm -f $launch_file
echo $fstr >> $launch_file
printf $BLINE
printf "\n\n"
echo "You're all done! You can now launch your node with the following command:\n"
echo "     ${PURPLE}strided start${NC}\n"
echo "Or, if you'd prefer:\n"
echo "     ${PURPLE}sh $launch_file${NC}\n"
echo "Just make sure $BINARY_LOCATION is in your PATH."

sleep 2
printf "\nNow for the fun part.\n\n"
sleep 2

while true; do
    read -p "$(echo $PURPLE"Do you want to launch your blockchain? [y/n] "$NC)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# kill ports if they're already running
PORT_NUMBER=6060
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill
PORT_NUMBER=26657
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill 
# we likely don't need to kill this - look into why this is causing issues
PORT_NUMBER=26557
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill


sh $launch_file
