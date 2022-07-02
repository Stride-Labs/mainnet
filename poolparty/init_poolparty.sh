#!/bin/bash

clear 

while true; do
    read -p "Please type in name for your local node: " NODE_NAME
    if [ -z "$NODE_NAME" ]; then
    echo 'Please enter a node name.'
    else
        break
    fi
done
# curl -L install.poolparty.stridelabs.co | sh
# curl https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/init_poolparty.sh | sh
TESTNET="internal"
INSTALL_FOLDER="$HOME/.stride/$TESTNET"
STRIDE_FOLDER="$INSTALL_FOLDER/stride"

mkdir -p $STRIDE_FOLDER
cd $INSTALL_FOLDER
echo "Installing to $STRIDE_FOLDER\n"

if [ -d $STRIDE_FOLDER ] 
then
    while true; do
        read -p "Do you want to overwrite your existing $TESTNET blockchain and reinitialize? [y/n] " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.\n";;
        esac
    done
fi

rm -rf $STRIDE_FOLDER > /dev/null 2>&1
rm launch_testnet.sh > /dev/null 2>&1

echo "\nPulling Stride repo..."
git clone https://github.com/Stride-Labs/stride.git > /dev/null 2>&1
cd stride 
git checkout 62e897c34f66d9cd0a7e0307517cd41c55a8f473 > /dev/null 2>&1

mkdir $STRIDE_FOLDER/build/
mkdir $STRIDE_FOLDER/build/stride/

make local-build
STRIDE_HOME=$STRIDE_FOLDER/build/stride/
echo "Initializing chain..."

$STRIDE_FOLDER/build/strided init $NODE_NAME --home $STRIDE_HOME --chain-id STRIDE --overwrite > /dev/null 2>&1

# Now pull the genesis file
curl https://bafkreid3dxxitn75gwr6dllhouasrdzgwmlj6wcyvrbspzzlsi453iskye.ipfs.dweb.link/ -o $STRIDE_FOLDER/build/stride/config/genesis.json > /dev/null 2>&1

# # add persistent peer
config_path="$STRIDE_FOLDER/build/stride/config/config.toml"
PEER_ID="2ccf88e4c18e072f6173f80392ed5e61fccaf719@stride-node1.internal.stridenet.co:26656"
sed -i -E "s|persistent_peers = \".*\"|persistent_peers = \"$PEER_ID\"|g" $config_path

fstr="$STRIDE_FOLDER/build/strided start --home $STRIDE_FOLDER/build/stride/"

launch_file=$INSTALL_FOLDER/launch_poolparty.sh

echo $fstr >> $launch_file

while true; do
    read -p "Do you want to launch your blockchain? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

sh $launch_file