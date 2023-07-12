# Stride's Network

![Stride](assets/stride-banner.png)

This contains instructions for how to connect to Stride!

We've tried to keep the instructions as simple as possible, but if you have any questions, please don't hesitate to contact us over [email](mailto:hello@stridelabs.co), on [Twitter](https://twitter.com/stride_zone), or at our [Discord](https://stride.zone/discord).

Requirements for running a node are fairly minimal. You should have a 4 CPU 32 GB RAM machine. We've only tested this build on OSX and Linux machines, but we hope to support Windows soon.


## Installation

We'll release a more detailed connection script soon, but for now, look at the [chain registry](https://github.com/cosmos/chain-registry/tree/master/stride) for connection info for Stride. A quick summary:

    chain-id = stride-1
    stride hash = a3eff2dc5a33a64bd86341b40f980ce58a736b11
    stride version = v11.0.0
    genesis file = https://raw.githubusercontent.com/Stride-Labs/mainnet/main/mainnet/genesis.json

We would recommend using a snapshot as opposed to connecting through state sync. We've found snapshots can fully catch up to mainnet slightly more consistently than state sync. Many members of the Stride community consistently upload high-quality snapshots. A couple to highlight are [Polkachu](https://polkachu.com/tendermint_snapshots/stride) and [BccNodes](https://bccnodes.com/m/stride/#snapshot).

## Being a Validator

We are hoping to release a more detailed validator guide later. For now, we strongly recommend running a setup with a Sentry node and signed using [Horcrux](https://github.com/strangelove-ventures/horcrux).

We recommend validators have a minimum 8 CPU 64 GB RAM machines.

## Setting up a Node
- [Instructions on Linux](https://github.com/Stride-Labs/mainnet/tree/main/mainnet)
