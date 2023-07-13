
sudo chmod 777 $HOME/go/bin/

# LINUX GO 1.18 INSTALL INSTRUCTIONS

wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
echo "export PATH=\$PATH:$HOME/go/bin" >> ~/.profile
echo "export GOPATH=~/.go" >> ~/.profile
source ~/.profile

# INSTALL IN ALPINE
sudo apk add --no-cache git make musl-dev go
export GOROOT=/usr/lib/go
export GOPATH=/go
export PATH=/go/bin:$PATH

bash -c "$(curl -sSL https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/gaia/join_gaia.sh)"

gaiad keys add --recover 

sudo cp gaiad.service /etc/systemd/system/gaiad.service
sudo chmod 644 /etc/systemd/system/gaiad.service

sudo systemctl daemon-reload

sudo systemctl start gaiad
sudo systemctl status gaiad
sudo systemctl enable gaiad

journalctl -u gaiad.service -n 30

gaiad tendermint show-validator

# gaiad tx staking create-validator --amount 1000uatom --from aidan --pubkey '{"@type":"/cosmos.crypto.ed25519.PubKey","key":"vrsv13BKvuIobtmtof8sxsE44hNl2uq6MoACBp9Mq/U="}' --commission-max-change-rate 0.1 --commission-max-rate 0.1 --commission-rate 0.1 --min-self-delegation 1 --chain-id GAIA