#!/bin/bash
set -e
clear 

# bash -c "$(curl -sSL https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/join_gaia.sh)"

SCRIPT_VERSION="v0.0.2"

PURPLE='\033[0;35m'
BOLD="\033[1m"
BLUE='\033[1;34m'
ITALIC="\033[3m"
NC="\033[0m"
LOG_FILE="install.log"

GAIA_COMMIT_HASH=5b47714dd5607993a1a91f2b06a6d92cbb504721
GENESIS_URL=https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/gaia_genesis.json
PERSISTENT_PEER_ID="98ed4fbbaf04cb21076dcac959d91b2efa75d02c@gaia.poolparty.stridenet.co:26656"

printf "\n\n${BOLD}Welcome to the setup script to join Stride's testnet ${PURPLE}PoolParty${NC}${ITALIC}${BLUE} as a Gaia node! ${NC}\n\n"
printf "This script will guide you through setting up your very own Poolparty Gaia node locally.\n"
printf "You're currently running $BOLD$SCRIPT_VERSION$NC of the setup script.\n\n"

printf "Before we begin, let's make sure you have all the required dependencies installed.\n"
DEPENDENCIES=( "git" "go" "jq" "lsof" "gcc" )
missing_deps=false
for dep in ${DEPENDENCIES[@]}; do
    printf "\t%-8s" "$dep..."
    if [[ $(type $dep 2> /dev/null) ]]; then
        printf "$BLUE\xE2\x9C\x94$NC\n" # checkmark
    else
        missing_deps=true
        printf "$PURPLE\xE2\x9C\x97$NC\n" # X
    fi
done
if [[ $missing_deps = true ]]; then
    printf "\nPlease install al required dependencies and rerun this script!\n"
    exit 1
fi

printf "\nAwesome, you're all set.\n"

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

printf "\nNext, we need to give your node a nickname. "

node_name_prompt="What would you like to call it? "
while true; do
    read -p "$(printf $PURPLE"$node_name_prompt"$NC)" NODE_NAME
    if [[ ! "$NODE_NAME" =~ ^[A-Za-z0-9-]+$ ]]; then
        printf '\nNode names can only container letters, numbers, and hyphens.\n'
        node_name_prompt="Please enter a new name. "
    else
        break
    fi
done

TESTNET="poolparty"
INSTALL_FOLDER="$HOME/.gaia/$TESTNET"
GAIA_FOLDER="$HOME/.gaia"
LOG_PATH=$GAIA_FOLDER/$LOG_FILE

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

printf "\nGreat, now we'll download the latest version of Stride's Gaia.\n"
printf "Stride will keep track of blockchain state in ${BOLD}$GAIA_FOLDER${NC}\n\n"

if [ -d $GAIA_FOLDER ] 
then
    printf "${BOLD}Looks like you already have Gaia installed.${NC}\n"
    printf "Proceed carefully, because you won't be able to recover your data if you overwrite it.\n\n"
    pstr="Do you want to overwrite your existing Gaia installation and proceed? [y/n] "
    while true; do
        read -p "$(printf $PURPLE"$pstr"$NC)" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.\n";;
        esac
    done
fi
printf $BLINE

rm -rf $GAIA_FOLDER 

mkdir -p $INSTALL_FOLDER
cd $INSTALL_FOLDER

date > $LOG_PATH

printf "\nFetching Stride's Gaia code...\n"
git clone https://github.com/Stride-Labs/gaia.git >> $LOG_PATH 2>&1
cd $INSTALL_FOLDER/gaia 
git checkout $GAIA_COMMIT_HASH >> $LOG_PATH 2>&1

# pick install location
DEFAULT_BINARY="$HOME/go/bin"
printf "\nAlmost there! "
rstr="Where do you want to install your gaia binary? [default: $DEFAULT_BINARY] "
read -p "$(printf $PURPLE"$rstr"$NC)" BINARY_LOCATION
if [ -z "$BINARY_LOCATION" ]; then
    BINARY_LOCATION=$DEFAULT_BINARY
fi
mkdir -p $BINARY_LOCATION
go build -mod=readonly -trimpath -o $BINARY_LOCATION ./... >> $LOG_PATH 2>&1
printf "\n"

printf $BLINE

BINARY=$BINARY_LOCATION/gaiad
printf "\nLast step, we need to setup your genesis state to match PoolParty.\n"

$BINARY init $NODE_NAME --home $GAIA_FOLDER --chain-id GAIA --overwrite >> $LOG_PATH 2>&1

# Now pull the genesis file
curl -L $GENESIS_URL -o $GAIA_FOLDER/config/genesis.json >> $LOG_PATH 2>&1

# # add persistent peer
config_path="$GAIA_FOLDER/config/config.toml"
app_path="$GAIA_FOLDER/config/app.toml"
sed -i -E "s|persistent_peers = \".*\"|persistent_peers = \"$PERSISTENT_PEER_ID\"|g" $config_path

# fetch state sync params
# fetched_state="$(curl -s https://gaia.poolparty.stridenet.co:445/commit | jq "{height: .result.signed_header.header.height, hash: .result.signed_header.commit.block_id.hash}")"
fetched_state="$(curl -s https://gaia.$TESTNET.stridenet.co:445/commit | jq "{height: .result.signed_header.header.height, hash: .result.signed_header.commit.block_id.hash}")"
height="$(echo $fetched_state | jq -r '.height')"
hash="$(echo $fetched_state | jq -r '.hash')"
# sed -i -E "s|enable = false|enable = true|g" $config_path
sed -i -E "s|trust_height = 0|trust_height = $height|g" $config_path
sed -i -E "s|trust_hash = \"\"|trust_hash = \"$hash\"|g" $config_path
sed -i -E "s|trust_period = \"168h0m0s\"|trust_period = \"3600s\"|g" $config_path
statesync_rpc="gaia.$TESTNET.stridenet.co:26657,gaia.$TESTNET.stridenet.co:26657"
sed -i -E "s|rpc_servers = \"\"|rpc_servers = \"$statesync_rpc\"|g" $config_path
# sed -i -E 's|unsafe-cors = false|unsafe-cors = true|g' $app_path
sed -i -E 's|cors_allowed_origins = \[\]|cors_allowed_origins = ["*"]|g' $config_path
sed -i -E 's|enable = false|enable = true|g' $app_path
sed -i -E 's|127.0.0.1|0.0.0.0|g' $app_path


fstr="$BINARY start --home $GAIA_FOLDER"

launch_file=$INSTALL_FOLDER/launch_poolparty_gaia.sh
rm -f $launch_file
echo $fstr >> $launch_file
printf $BLINE
printf "\n\n"
printf "You're all done! You can now launch your node with the following command:\n\n"
printf "     ${PURPLE}gaiad start${NC}\n\n"
printf "Or, if you'd prefer:\n\n"
printf "     ${PURPLE}sh $launch_file${NC}\n\n"
printf "Just make sure $BINARY_LOCATION is in your PATH."

sleep 2
printf "\n\nNow for the fun part.\n\n"
sleep 2

while true; do
    read -p "$(printf $PURPLE"Do you want to launch your blockchain? [y/n] "$NC)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) printf "Please answer yes or no.\n";;
    esac
done

# kill ports if they're already running
PORT_NUMBER=6060
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs -r kill
PORT_NUMBER=26657
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs -r kill 
# we likely don't need to kill this - look into why this is causing issues
PORT_NUMBER=26557
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs -r kill


sh $launch_file
