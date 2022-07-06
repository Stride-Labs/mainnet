#!/bin/bash
set -e
clear 

SCRIPT_VERSION="v0.0.13"

# you can always install this script with
# curl -L install.poolparty.stridelabs.co | sh

PURPLE='\033[0;35m'
BOLD="\033[1m"
BLUE='\033[1;34m'
ITALIC="\033[3m"
NC="\033[0m"

STRIDE_COMMIT_HASH=77a95ac55991524e12dadf98a78eb6356ff3c42b
GENESIS_URL=https://bafkreieoeo7z7p55qbbk23zmvtcgj6dmavufvq5cvrsb4lzbgl5b7cfgum.ipfs.dweb.link/
PERSISTENT_PEER_ID="2d511c7a47e61a944fd41e37ad59ce4ffc7e31ab@stride-node1.internal.stridenet.co:26656"

printf "\n\n${BOLD}Welcome to the setup script for Stride's Testnet, ${PURPLE}PoolParty${NC}!\n\n"
printf "This script will guide you through setting up your very own Stride node locally.\n"
printf "You're currently running $BOLD$SCRIPT_VERSION$NC of the setup script.\n\n"

printf "Before we begin, let's make sure you have all the required dependencies installed.\n"
DEPENDENCIES=( "git" "go" "jq" )
missing_deps=false
for dep in ${DEPENDENCIES[@]}; do
    printf "\t%-7s" "$dep..."
    if [[ $(type $dep 2> /dev/null) ]]; then
        printf "$BLUE\xE2\x9C\x94$NC\n" # checkmark
    else
        missing_deps=true
        printf "$PURPLE\xE2\x9C\x97$NC\n" # X
    fi
done
if [[ $missing_deps = true ]]; then
    printf "\nPlease install all required dependencies and rerun this script!\n"
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
        read -p "$(printf $PURPLE"$pstr"$NC)" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) printf "Please answer yes or no.\n";;
        esac
    done
fi
printf $BLINE

rm -rf $STRIDE_FOLDER > /dev/null 2>&1
rm -f launch_testnet.sh > /dev/null 2>&1

mkdir -p $INSTALL_FOLDER
cd $INSTALL_FOLDER

printf "\nFetching Stride's code...\n"
git clone https://github.com/Stride-Labs/stride.git > /dev/null 2>&1
cd $INSTALL_FOLDER/stride 
git checkout $STRIDE_COMMIT_HASH > /dev/null 2>&1

# pick install location
DEFAULT_BINARY="$HOME/go/bin"
printf "\nAlmost there! "
rstr="Where do you want to install your stride binary? [default: $DEFAULT_BINARY] "
read -p "$(printf $PURPLE"$rstr"$NC)" BINARY_LOCATION
if [ -z "$BINARY_LOCATION" ]; then
    BINARY_LOCATION=$DEFAULT_BINARY
fi
mkdir -p $BINARY_LOCATION
go build -mod=readonly -trimpath -o $BINARY_LOCATION ./... > /dev/null 2>&1
printf "\n"

printf $BLINE

BINARY=$BINARY_LOCATION/strided
printf "\nLast step, we need to setup your genesis state to match PoolParty.\n"
printf "\nDownloading data from IPFS...\n"

$BINARY init $NODE_NAME --home $STRIDE_FOLDER --chain-id STRIDE --overwrite > /dev/null 2>&1

# Now pull the genesis file
curl $GENESIS_URL -o $STRIDE_FOLDER/config/genesis.json > /dev/null 2>&1

# # add persistent peer
config_path="$STRIDE_FOLDER/config/config.toml"
sed -i -E "s|persistent_peers = \".*\"|persistent_peers = \"$PERSISTENT_PEER_ID\"|g" $config_path

# fetch state sync params
fetched_state="$(curl -s https://stride-node3.$TESTNET.stridenet.co:445/commit | jq "{height: .result.signed_header.header.height, hash: .result.signed_header.commit.block_id.hash}")"
height="$(echo $fetched_state | jq -r '.height')"
hash="$(echo $fetched_state | jq -r '.hash')"
echo "HASH"
echo $hash
echo "HEIGHT"
echo $height
sed -i -E "s|enable = false|enable = true|g" $config_path
sed -i -E "s|trust_height = 0|trust_height = $height|g" $config_path
sed -i -E "s|trust_hash = \"\"|trust_hash = \"$hash\"|g" $config_path
sed -i -E "s|trust_period = \"168h0m0s\"|trust_period = \"3600s\"|g" $config_path
statesync_rpc="stride-node2.$TESTNET.stridenet.co:26657,stride-node3.$TESTNET.stridenet.co:26657"
sed -i -E "s|rpc_servers = \"\"|rpc_servers = \"$statesync_rpc\"|g" $config_path

fstr="$BINARY start --home $STRIDE_FOLDER"

launch_file=$INSTALL_FOLDER/launch_poolparty.sh
rm -f $launch_file
echo $fstr >> $launch_file
printf $BLINE
printf "\n\n"
printf "You're all done! You can now launch your node with the following command:\n\n"
printf "     ${PURPLE}strided start${NC}\n\n"
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
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill
PORT_NUMBER=26657
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill 
# we likely don't need to kill this - look into why this is causing issues
PORT_NUMBER=26557
lsof -i tcp:${PORT_NUMBER} | awk 'NR!=1 {print $2}' | xargs kill

read -p "$(printf $PURPLE"\nCreate a systemd service file to run the node? [y/n] "$NC)" is_create_systemd_file
if [[ "$is_create_systemd_file" =~ ^([Yy])$ ]]
then
    tee /etc/systemd/system/strided.service > /dev/null <<EOF
[Unit]
Description=Strided Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which strided) start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && \
    systemctl enable strided.service && \
    systemctl restart strided.service && \
    journalctl -u strided.service -f -o cat
else
    sh $launch_file
fi
