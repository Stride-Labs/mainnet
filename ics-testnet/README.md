# Stride's Network

![Stride](../assets/stride-banner.png)

This contains instructions for how to connect to Stride!

    chain-id = stride-ics-testnet-1
    stride hash = 3aeb075f36cb12711201a7f17e8b8d856bd99a01
    genesis file = https://raw.githubusercontent.com/Stride-Labs/mainnet/ics-testnet/ics-testnet/genesis.json
    peer = cd34b9f506a4840d5ea69095403029056862a2e1@stride-direct.testnet-2.stridenet.co:26656
    seed = 0b3e01c43f733e85b3d3f1a012256c5e19be796c@seed.testnet-2.stridenet.co:26656

If you'd prefer to pull an officially built binary, [this docker image](https://hub.docker.com/layers/stridelabs/ics-testnet/stride/images/sha256-66951c86333ee592eef3d6fe275c5c1fc34f2e91f092a9f89d605e3a4497f1c7?context=repo) will also contain the latest (3aeb0). To pull it locally, please run `docker pull stridelabs/ics-testnet:stride`.

The file `join_ics_testnet.sh` should run through a standard installation with Cosmovisor. This has only been tested on OSX, but the commands should be quite similar on Linux as well.