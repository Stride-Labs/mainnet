# Stride's Testnet - PoolParty

![Stride](assets/stride-banner.png)

This contains instructions for how to connect to Stride's testnet, PoolParty!

We've tried to keep the instructions as simple as possible, but if you have any questions, please don't hesitate to contact us over [email](mailto:hello@stridelabs.co), on [Twitter](https://twitter.com/stride_zone), or at our [Discord](https://stride.zone/discord).

Requirements for this testnet are quite minimal. You should have a 4 CPU 32 GB RAM machine. We've only tested this build on OSX and Linux machines, but we hope to support Windows soon.

## Installation

Run the following command to install PoolParty

```
sh -c "$(curl -sSL install.poolparty.stridelabs.co)"
```

## Running Stride Commands

Please add the repo with your Stride binary (defaults to `$HOME/go/bin`) to your `.bashrc` or `.zshrc` file. Then, you can run `strided` automatically.

For example, run `strided q bank balances stride159atdlc3ksl50g0659w5tq42wwer334ajl7xnq` to see the balance of Stride's address.

Another, practical example, if you run 

    strided keys list

you can see your local keys. If you wish to make a new account, please run 

    strided keys add <NAME>

If you run `strided q help`, you'll see a list of potential options. Some useful flows might be 

    strided tx stakeibc liquid-stake
    strided tx stakeibc redeem-stake

## Being a Validator

If you want to convert your node into a validator, please run 

    strided tx staking create-validator

and follow the prompts.

## Block Explorer

For now, we're hosting a Ping.Pub block explorer [here](https://internal-explorer.stride.zone/). We're working on integrating a more robust block explorer, stay tuned. 

## FAQ

### Where can I get some tokens?

To get tokens, message `$faucet {{ADDRESS}}` on Discord. For example, I would type `$faucet stride159atdlc3ksl50g0659w5tq42wwer334ajl7xnq`. 

Please don't spam this.

### Are there any variables I should know about?

If your local `strided` is asking you for any of these, please know:

    CHAIN_ID = STRIDE
    KEYRING_BACKEND = os
    HOST_ZONE = GAIA 
    STRIDE_CURRENCY = ustrd (1,000,000 ustrd = 1 STRD)
    GAIA_CURRENCY = uatom (1,000,000 uatom = 1 ATOM)

###  How can I relaunch my Node?

When you first install your testnet, you should have seen two `sh` commands printed at the end. These contain instructions for how to connect to your testnet. 

If you used the presets, you should be able to run the following command to relaunch your node. 

``` strided start```
or
``` sh $HOME/.stride/poolparty/launch_poolparty.sh```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. We also welcome all discussion in #engineering or #questions in our [Discord](https://stride.zone/discord). 
