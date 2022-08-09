# Stride's Testnet - PoolParty

![Stride](assets/stride-banner.png)

This contains instructions for how to connect to Stride's testnet, PoolParty!

We've tried to keep the instructions as simple as possible, but if you have any questions, please don't hesitate to contact us over [email](mailto:hello@stridelabs.co), on [Twitter](https://twitter.com/stride_zone), or at our [Discord](https://stride.zone/discord).

Requirements for this testnet are quite minimal. You should have a 4 CPU 32 GB RAM machine. We've only tested this build on OSX and Linux machines, but we hope to support Windows soon.

## Installation

Run the following command to install PoolParty

```
bash -c "$(curl -sSL install.poolparty.stridelabs.co)"
```

## Upgrade t

If you've installed Poolparty with the standard install script, please run 

```
bash -c "$(curl -sSL https://raw.githubusercontent.com/stride-labs/testnet/main/poolparty/upgrade.sh)"
```

The upgrade script uses the file structure and naming defined by the default install script. If you installed Poolparty in a different way, please do NOT use the upgrade script, it may not function properly.

If you want to upgrade manually (or did not do the standard installation), please use this commit hash to upgrade your binary: `15e65e9a364804671425051606fe0be6536452fe`. We strongly recommend using Cosmovisor to handle your upgrade, so that you will automatically upgrade after the gov proposal passes. 

## Running Stride Commands

Please add the repo with your Stride binary (defaults to `$HOME/go/bin`) to your `.bashrc` or `.zshrc` file. Then, you can run `strided` automatically.

For example, run `strided q bank balances stride159atdlc3ksl50g0659w5tq42wwer334ajl7xnq` to see the balance of Stride's address.

Another, practical example, if you run 

    strided keys list

you can see your local keys. If you wish to make a new account, please run 

    strided keys add <NAME>
    
If you already have a wallet and you want to restore it

    strided keys add <NAME> --recover
    
If you run `strided q help`, you'll see a list of potential options. Some useful flows might be 

    strided tx stakeibc liquid-stake
    strided tx stakeibc redeem-stake

## Being a Validator

If you want to convert your node into a validator, please run 

    strided tx staking create-validator

and follow the prompts.

## Block Explorer

For now, we're hosting a Ping.Pub block explorer [here](https://poolparty.stride.zone/). We're working on integrating a more robust block explorer, stay tuned. 

## FAQ

### Where can I get some tokens?

To get tokens, message `$faucet {{ADDRESS}}` on Discord. For example, I would type `$faucet stride159atdlc3ksl50g0659w5tq42wwer334ajl7xnq`. 

Please don't spam this.

### Are there any variables I should know about?

If your local `strided` is asking you for any of these, please know:

    CHAIN_ID = STRIDE-TESTNET-2
    KEYRING_BACKEND = test
    HOST_ZONE = GAIA 
    STRIDE_CURRENCY = ustrd (1,000,000 ustrd = 1 STRD)
    GAIA_CURRENCY = uatom (1,000,000 uatom = 1 ATOM)
    GAIA_CURRENCY_ON_STRIDE = ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2

###  How can I relaunch my Node?

When you first install your testnet, you should have seen two `sh` commands printed at the end. These contain instructions for how to connect to your testnet. 

If you used the presets, you should be able to run the following command to relaunch your node. 

``` strided start```
or
``` sh $HOME/.stride/poolparty/launch_poolparty.sh```

### Why does my node need a nickname?

Your node's nickname is how others can see it on the block explorer. For example, if you become a validator, you'll appear as your node's nickname. 

### I'm running into a permissions issue when building, what should I do?

If you're running into a permission error of the flavor 

    mkdir: {{path}}: Permission Denied

If so, you should run `chmod +rw {{path}}` to fix the permissions.

### I'm running into an error building, what could it be?

Please DM us your logfile, located at `$HOME/.stride/install.log`, and we can help you debug.

One thing to check, Stride requires `go` version 1.18. Please install this [here](https://go.dev/dl/).

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. We also welcome all discussion in #engineering or #questions in our [Discord](https://stride.zone/discord). 
