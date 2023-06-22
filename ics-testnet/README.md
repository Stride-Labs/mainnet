# Stride's Network

![Stride](../assets/stride-banner.png)

This contains instructions for how to connect to Stride!

    chain-id = stride-ics-testnet-2
    stride hash = a3eff2dc5a33a64bd86341b40f980ce58a736b11
    genesis file = https://raw.githubusercontent.com/Stride-Labs/mainnet/ics-testnet/ics-testnet/genesis.json
    peer = d747545dbab1eb86caff7ec64fca3b7f2ace07fd@stride-direct.testnet-2.stridenet.co:26656

If you'd prefer to pull an officially built binary, [this docker image](https://hub.docker.com/layers/stridelabs/ics-testnet/stride/images/sha256-3268198b39fa9e3b6107f352f49d28c5c78939e1147370b166f848dbd112186e?context=repo) will also contain the latest (v10.0.0). To pull it locally, please run `docker pull stridelabs/ics-testnet:stride`.

The file `join_ics_testnet.sh` should run through a standard installation with Cosmovisor. This has only been tested on OSX, but the commands should be quite similar on Linux as well.