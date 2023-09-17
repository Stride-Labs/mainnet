# Stride's Network

![Stride](assets/stride-banner.png)

This contains instructions for how to connect to Stride!

We've tried to keep the instructions as simple as possible, but if you have any questions, please don't hesitate to contact us over [email](mailto:hello@stridelabs.co), on [Twitter](https://twitter.com/stride_zone), or at our [Discord](https://stride.zone/discord).

Requirements for running a node are fairly minimal. You should have a 4 CPU 32 GB RAM machine. We've only tested this build on OSX and Linux machines, but we hope to support Windows soon.


## Installation

Please look at the [chain registry](https://github.com/cosmos/chain-registry/tree/master/stride) for connection info for Stride. A quick summary:

    chain-id = stride-1
    stride hash = 52581d22459e29b340605edaaada2aaf87d081cc
    stride version = v14.0.0
    genesis file = https://raw.githubusercontent.com/Stride-Labs/mainnet/main/mainnet/genesis.json
    seeds = ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:12256, babc3f3f7804933265ec9c40ad94f4da8e9e0017@seed.rhinostake.com:12256, 20e1000e88125698264454a884812746c2eb4807@seeds.lavenderfive.com:12256

We would recommend using a snapshot as opposed to connecting through state sync. We've found snapshots can fully catch up to mainnet slightly more consistently than state sync. Many members of the Stride community consistently upload high-quality snapshots. A couple to highlight are [Polkachu](https://polkachu.com/tendermint_snapshots/stride) and [BccNodes](https://bccnodes.com/m/stride/#snapshot).

[This script](https://github.com/Stride-Labs/mainnet/blob/main/mainnet/join_stride.sh) will also help you connect your node to Stride's mainnet. Please note that this script is intended as an aid, and might not suit all purposes. 

## Getting Ready for the Stride-ICS Migration

If you are a current Stride or Cosmos Hub validator and are preparing for the July 19th ICS Migration, please check the `ics-instructions` folder in this repo for more instructions. If you have any further questions, please reach out on Discord or Telegram!

## Setting up a Node
- [Instructions on Linux](https://github.com/Stride-Labs/mainnet/tree/main/mainnet)
