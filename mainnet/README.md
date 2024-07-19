## Easy Setup

For most casual use cases, we'd recommended setting up your node with the `join_stride.sh` file in this repo. You can do this by running this command in your local shell.

```
bash -c "$(curl -sSL node.stride.zone/install)"
```

More connection info (e.g. genesis, seeds, etc) can be found [here](https://github.com/Stride-Labs/mainnet/tree/main).

Please read on for more detailed setup instructions.

## Setting up a Node

### Linux

Make sure your system is updated and set the system parameters correctly:
```
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential curl wget jq
sudo su -c "echo 'fs.file-max = 65536' >> /etc/sysctl.conf"
sudo sysctl -p
```

#### Install go
First remove any existing old Go installation:
```
sudo rm -rf /usr/local/go
```

Install the latest version of Go using this helpful script and move to the /usr folder:
```
curl https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash
sudo mv $HOME/.go /usr/local/
```

#### Update environment variables to include go
```
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/.go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/.go/bin:$HOME/go/bin
EOF
source $HOME/.profile
```

Check if go is correctly installed:
```
go version
```
This should return something like "go version go1.18.1 linux/amd64"

#### Stride Binary
Install the Stride binary
```
sudo apt-get install git
git clone https://github.com/Stride-Labs/stride
cd stride
git checkout v22.0.0
make install
strided version
```

#### Configure the binary
```
strided keys add <key-name>
strided config chain-id stride-1
strided init <your_custom_moniker> --chain-id stride-1
curl https://raw.githubusercontent.com/Stride-Labs/mainnet/main/mainnet/genesis.json > ~/.stride/config/genesis.json
sudo ufw allow 26656
```

Set the seed in the config.toml (find seeds here: https://github.com/cosmos/chain-registry/blob/master/stride/chain.json):
```
nano $HOME/.stride/config/config.toml
seeds=""
indexer = "null"
```
Configure also the app.toml:
```
minimum-gas-prices = 0.001ustrd
pruning: "custom"
pruning-keep-recent = "100"
pruning-keep-every = "0"
pruning-interval ="10"
snapshot-interval = 1000
snapshot-keep-recent = 2
```

#### Create the service file for Stride to make sure it remains running at all times:
```
sudo tee /etc/systemd/system/strided.service > /dev/null <<EOF
[Unit]
Description=Stride Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which strided) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo mv /etc/systemd/system/strided.service /lib/systemd/system/
```

#### Start the binary
```
sudo -S systemctl daemon-reload
sudo -S systemctl enable strided
sudo -S systemctl start strided
sudo systemctl enable strided.service && sudo systemctl start strided.service
```

Monitor using:
```
systemctl status strided
sudo journalctl -u strided -f
```
