#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

NODE_NAME=$1
echo "\n"
if [ -z "$NODE_NAME" ]; then
  echo 'Please pass in your local node name, e.g. ./init_poolparty.sh YOUR_NODE_NAME'
  exit 1
elif [ "$NODE_NAME" == "YOUR_NODE_NAME" ]; then
  echo 'Please name your node something other than YOUR_NODE_NAME'
  exit 1
fi

cd $SCRIPT_DIR

STRIDE_FOLDER="$SCRIPT_DIR/stride/"

if [ -d $STRIDE_FOLDER ] 
then
    while true; do
        read -p "Do you want to delete the folder $STRIDE_FOLDER and proceed? You CANNOT reverse this decision. [y/n]
                " yn
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
git checkout 00519c8813e1fcc967b67c17776862d25b821893 > /dev/null 2>&1

mkdir $STRIDE_FOLDER/build/
mkdir $STRIDE_FOLDER/build/stride/

make local-build
STRIDE_HOME=$STRIDE_FOLDER/build/stride/
echo "Initializing chain..."

$STRIDE_FOLDER/build/strided init $NODE_NAME --home $SCRIPT_DIR/stride/build/stride/ --chain-id STRIDE --overwrite > /dev/null 2>&1

# Now pull the genesis file
curl https://bafkreidmprsdsfu43xd52xjyavwxrb43mb5rpqjmufa2v6w5pjamdhbxcy.ipfs.dweb.link/ -o $STRIDE_FOLDER/build/stride/config/genesis.json > /dev/null 2>&1

# # add persistent peer
config_path="$STRIDE_FOLDER/build/stride/config/config.toml"
PEER_ID="141cdd0bbef653db81192d2e57f75c7976cc87cd@stride-node1.internal.stridenet.co:26656"
sed -i -E "s|persistent_peers = \".*\"|persistent_peers = \"$PEER_ID\"|g" $config_path

fstr="$STRIDE_FOLDER/build/strided start --home $STRIDE_FOLDER/build/stride/"

launch_file=$SCRIPT_DIR/launch_poolparty.sh

echo $fstr >> $launch_file

while true; do
    read -p "Do you want to launch your blockchain? [y/n]
            " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

sh $launch_file