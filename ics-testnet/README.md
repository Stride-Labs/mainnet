# Stride's Network

![Stride](../assets/stride-banner.png)

This contains instructions for how to connect to Stride!

    chain-id = stride-ics-testnet-2
    stride hash = 1fbd939c3c2440e76a89d99740b804baaba65657
    genesis file = https://raw.githubusercontent.com/Stride-Labs/mainnet/ics-testnet/ics-testnet/genesis.json
    peer = c7a9ff8e11ce7e30fb0d5ccf2f6dba34e81b5bc3@stride-direct.testnet-2.stridenet.co:26656

If you'd prefer to pull an officially built binary, [this docker image](https://hub.docker.com/layers/stridelabs/ics-testnet/stride/images/sha256-aecb170d1e131b9bd5a9105a06023e7940555922d6727c8ed207610738dc68c2?context=repo) will also contain the latest (1fbd). To pull it locally, please run `docker pull stridelabs/ics-testnet:stride`.

The file `join_ics_testnet.sh` should run through a standard installation with Cosmovisor. This has only been tested on OSX, but the commands should be quite similar on Linux as well.