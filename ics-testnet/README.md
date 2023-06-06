# Stride's Network

![Stride](../assets/stride-banner.png)

This contains instructions for how to connect to Stride!

    chain-id = stride-ics-testnet-1
    stride hash = 3aeb075f36cb12711201a7f17e8b8d856bd99a01
    genesis file = https://raw.githubusercontent.com/Stride-Labs/mainnet/ics-testnet/ics-testnet/genesis.json
    peer = cd34b9f506a4840d5ea69095403029056862a2e1@stride-direct.testnet-2.stridenet.co:26656

[This](docker pull stridelabs/ics-testnet:stride) docker image will also contain the latest binary, if you'd prefer to compare against an officially built version.

The file `join_ics_testnet.sh` should run through a standard installation with Cosmovisor. This has only been tested on OSX, but the commands should be quite similar on Linux as well.