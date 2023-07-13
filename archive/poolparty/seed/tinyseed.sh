#!/bin/bash

set -e

sudo apt-get install git make wget -y

# install go
wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
echo "export PATH=\$PATH:$HOME/go/bin" >> ~/.profile
echo "export GOPATH=~/.go" >> ~/.profile
source ~/.profile

cd ~
git clone https://github.com/notional-labs/tinyseed
cd tinyseed
go mod tidy
go install .

export ID=STRIDE-TESTNET-2
export SEEDS=b61ea4c2c549e24c1a4d2d539b4d569d2ff7dd7b@stride-node1.poolparty.stridenet.co:26656
tinyseed