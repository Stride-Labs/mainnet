#!/bin/bash

set -e

sudo apt-get install git make wget  -y
sudo apt-get install libc6-compat
# install go
wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
echo "export PATH=\$PATH:$HOME/go/bin" >> ~/.profile
echo "export GOPATH=~/.go" >> ~/.profile
source ~/.profile

# install tenderseed
cd ~
git clone https://github.com/binaryholdings/tenderseed.git
cd $HOME/tenderseed
make
make build/tenderseed.elf
make build/tenderseed

config_path="$HOME/.tenderseed/config/config.toml"
PERSISTENT_PEER_ID="21f8d9c493f5de8f61f56dd315ef91009a3e8913@stride-node1.poolparty.stridenet.co:26656"
sed -i -E "s|seeds = \".*\"|seeds = \"$PERSISTENT_PEER_ID\"|g" $config_path
sed -i -E "s|chain_id = \".*\"|chain_id = \"STRIDE-TESTNET-2\"|g" $config_path
sed -i -E "s|max_num_inbound_peers = .*|max_num_inbound_peers = 1000|g" $config_path
sed -i -E "s|max_num_outbound_peers = .*|max_num_outbound_peers = 1000|g" $config_path

/home/vishal/tenderseed/build/tenderseed --seeds=48b1310bc81deea3eb44173c5c26873c23565d33@stride-testnet-2-node1.poolparty.stridenet.co:26656,8e301628c3f86ba6f875e4978d73bf532198151b@stride-testnet-2-node2.poolparty.stridenet.co:26656,3766ebe762f6825b3498e97a3b93f0ee1e8e0faa@stride-testnet-2-node3.poolparty.stridenet.co:26656 -chain-id STRIDE-TESTNET-2 start


sudo cp seed.service /etc/systemd/system/seed.service
sudo chmod 644 /etc/systemd/system/seed.service

sudo systemctl daemon-reload

sudo systemctl stop seed
sudo systemctl start seed
sudo systemctl status seed
sudo systemctl enable seed

journalctl -u seed.service -n 30
