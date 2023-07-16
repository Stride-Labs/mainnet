# `stride-1`

# Section 1: Overview

Stride's launch on the Replicated Security will be different from other consumer chain launches. Other chain launches spawned a new chain from a fresh genesis state, but Stride already exists as a sovereign chain.

### Required tasks
At a high-level, as a validator, you have the following tasks. You *must* complete all 3 tasks.


1. Sync a stride-1 node ASAP (see step 1 below)
2. Complete key assignment ASAP and **before** the spawn time (or commit now to using your Cosmos Hub validator key). For emphasis, you must do key assignment or commit to using your Hub validator key **before** spawn time or there will be liveness issues with Stride.
3. Execute the Stride v12 upgrade on 2023-07-19, around 5pm UTC

Do these three tasks or the launch will fail!!!

### How will the sovereign -> consumer chain transition work on the Cosmos Hub?

* Stride side: Stride mainnet is currently live (chain-id: `stride-1`). Stride mainnet will perform a software upgrade and at the upgrade height (4616678) it will transition to the Cosmos Hub's validator set.
* Cosmos Hub side: A consumer-addition proposal to add Stride [has passed](https://www.mintscan.io/cosmos/proposals/799). Shortly after the spawn time (2023-07-19T05:00:00Z), validators will receive the CCV state. This CCV state will be used to patch the original stride chain’s genesis file, creating a new file: ccv.json. That will be pushed to this repo, after spawn time, but before the upgrade occurs. ccv.json must be placed in the node's home directory, in order to start a stride node after the upgrade to a consumer chain.

### What do you need to do to participate in the mainnet launch on 2023-07-19, around 5pm UTC?
See the table below for a breakdown of steps you'll need to follow throughout the process. 

# Section 2: Launch sequence
## ⚠️  Complete STEPS 1-3 (join Stride testnet with a full node and do key assignment) ASAP ⚠️

### Joining instructions
Follow along with Stride's block explorer here: https://www.mintscan.io/stride

For step 1, you can try using Stride’s joining script here: https://github.com/Stride-Labs/mainnet/blob/main/mainnet/join_stride.sh.

Full details here: https://github.com/Stride-Labs/mainnet/tree/ics-mainnet/mainnet

Otherwise you may manually join `stride-1` using these notes:
* Joining instructions: https://github.com/Stride-Labs/mainnet/tree/main/ics-instructions
* Genesis file: https://raw.githubusercontent.com/Stride-Labs/mainnet/main/mainnet/genesis.json
* Pre-transition stride binary commit: `4b5d80ac5cafb418debc8a860959d4a6c6797cfb`
* Stride’s GitHub repository: https://github.com/stride-Labs/stride
* Building instructions for stride’s binary: `make install`
* Go version: 1.19
* Seed id: `ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:12256`
* Chain ID: `stride-1`
* Post-upgrade stride binary commit (run with this binary after the upgrade): [`bbf0bb7f52878f3205c76bb1e96662fe7bd7af8d`](https://github.com/Stride-Labs/stride/commit/bbf0bb7f52878f3205c76bb1e96662fe7bd7af8d)
  * You can use [link soon]() pre-built linux binary. E.g. `wget -O strided 'https://storage.googleapis.com/strided-binaries/strided'`
 
<details><summary>Detailed steps for manually joining Stride</summary>
<br>
 
 _Courtesy of Stakecito_

```sh
git clone https://github.com/Stride-Labs/stride.git
cd stride
git checkout `4b5d80ac5cafb418debc8a860959d4a6c6797cfb`
make install
strided init stride-node --chain-id stride-1

# Grab the genesis file
curl -L https://raw.githubusercontent.com/Stride-Labs/mainnet/main/mainnet/genesis.json -o $HOME/.stride/config/genesis.json
```

* Download a snapshot from [here](https://polkachu.com/tendermint_snapshots/stride).
* Start stride node, node should start catching up
* Node will panic on 2023-07-19 around 5pm UTC at the upgrade height: 4616678
* Stop the node

</details>

<details><summary>Detailed steps for transitioning Stride node from Stride testnet to validator on consumer chain</summary>
<br>

_Thanks to Bosco from Silk Nodes_

Download v12 Binary (v12.0.0 tag)
```sh
cd stride
git pull
git checkout bbf0bb7f52878f3205c76bb1e96662fe7bd7af8d
make install

# Please verify the version is v12
strided version
```

Make directories in cosmovisor and copy binaries
```
mkdir -p $HOME/.stride/cosmovisor/upgrades/v12/bin/
cp $HOME/go/bin/strided $HOME/.stride/cosmovisor/upgrades/v12/bin/
```

Download new Sovereign genesis (PENDING SPAWN TIME! NOT YET AVAILABLE!)
```
mkdir -p $NODE_HOME/config/
wget -O $NODE_HOME/config/ccv.json https://raw.githubusercontent.com/Stride-Labs/mainnet/main/ics-instructions/ccv.json
```

Restart the Service
```
sudo service stride restart && journalctl -u stride -f -o cat
```

</details>

## Launch Sequence
|Step|When?                                             |What do you need to do?                                                                       |What is happening?                                                                                                                              |
|----|--------------------------------------------------|----------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
|0   |Voting period for consumer-addition proposal. (DONE)     |[PROVIDER] Optional: Vote for the consumer-addition proposal.                                 |Passing the consumer-addition proposal on the provider side.                                                                                    |
|1   |ASAP (before spawn time)                                              |Join the Stride mainnet `stride-1` with the pre-transition binary as a full node (not validator) and sync to the tip of the chain.|Validator machines getting caught up on existing Stride chain's history                                                                         |
|2   |ASAP (before spawn time) |Build (or download) the target (post-transition) Stride binary. If you are using Cosmovisor, place place it in Cosmovisor `/upgrades/v12/bin` directory. If you are not using Cosmovisor, be ready to manually switch your binary at the upgrade halt height.|Setup for machines to switch from being a full node to a validator when the chain transitions.                                                  |
|3   | ASAP (before spawn time)                                 |[PROVIDER] If using key assignment, submit assign-consensus-key for `stride-1` with the keys on your full node. You can also just run with the same consensus key as your provider node. You absolutely **can not** do key assignment after spawn time, but before Stride is live. This will create liveness problems for Stride.|Key assignment (optional) to link provider and consumer validators.                                                                             |
|4   |Voting period for software upgrade                |Nothing                                                                                       |Passing the software upgrade proposal on the Stride side.                                                                                       |
|5   |Spawn time                                        |Nothing                                                                                       |ccv state becomes available                                                                                                                     |
|6   |After spawn time                                  |The `ccv.json` file will be provided in this repo. Alternatively, you can generate it yourself by exporting the ccv state and updating Stride's genesis file (instructions below). Place the newly generated `ccv.json` in the `$NODE_HOME/config` directory.   Do NOT replace the existing genesis file.|Adding the ccv state to the genesis file for the new consumer chain.                                                                            |
|7   |Upgrade height                                    |Restart your node with the post-transition binary. The upgrade handler will automatically read the existing genesis file and the new `ccv.json` file if they are correctly placed.|Stride chain halts to transition to being a consumer chain.                                                                                     |
|8   |3 blocks after upgrade height                     |Celebrate! :tada: 🥂                                                |Stride blocks are now produced by the provider validator set                                                                                    |

Optionally, you can generate `ccv.json` independently, like so (where genesis.json is Stride's genesis file)
```
gaiad q provider consumer-genesis stride-1 -o json > ccv-state.json
jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' genesis.json ccv-state.json > ccv.json
```

# Section 3: Key assignment 
**This is only relevant if you want to use a key that is different from your Cosmos Hub key.**


## IMPORTANT: ⚠️ **If you did not use the key assignment feature before spawn time, do not use it until the chain is live, stable and receiving VSCPackets from the provider! **⚠️

This cannot be emphasized enough. Do _not_ try to do key assignment after the spawn time, but before Stride is ICS secured. You can do key assignment before spawn time, or 1 week after spawn time. This problem created liveness problems for Neutron.

If you do not wish to reuse the private validator key from your provider chain, an alternative method is to use multiple keys managed by the Key Assignment feature.

⚠️ Ensure that the `priv_validator_key.json` on the consumer node is different from the key that exists on the provider node.

⚠️ The `AssignConsumerKey` transaction must be sent to the provider chain before the consumer chain's spawn time.

	# run this on the machine that you will use to run stride
	# the command gets the public key to use for stride
	$ strided tendermint show-validator
	{"@type":"/cosmos.crypto.ed25519.PubKey","key":"qVifseOYMsfeKnzSHlkEb+0ZZeuZrVPJ7sqMZJHAbBc="}
	
	# do this step on the provider machine
	# you should have a key available on the provider that you can use to sign the key assignment transaction
	$ STRIDE_KEY='{"@type":"/cosmos.crypto.ed25519.PubKey","key":"qVifseOYMsfeKnzSHlkEb+0ZZeuZrVPJ7sqMZJHAbBc="}'
	$ gaiad tx provider assign-consensus-key stride-1 $STRIDE_KEY --from <tx-signer> --home <home_dir> --gas 900000 -y -o json
	
	# confirm your key has been assigned
	$ GAIA_VALCONSADDR=$(gaiad tendermint show-address --home ~/.gaia)
	$ gaiad query provider validator-consumer-key stride-1 $GAIA_VALCONSADDR
	consumer_address: "<your_address>"


Read more on [Key Assignment](https://github.com/cosmos/interchain-security/blob/main/docs/docs/features/key-assignment.md). 

# Section 4: FAQ

**What are the latest instructions to join Stride mainnet as a node operator?**

Please see [here](https://github.com/Stride-Labs/mainnet/tree/main/mainnet).

**If I’m currently a validator on Stride’s mainnet, can I reuse the same validator key for the consumer chain? Will I need to perform a AssignConsumerKey tx with this key before spawn time?**

Validators must either assign a key or use the same key as on the Cosmos Hub. If you are both a Stride and a Hub validator, you can use your current Stride key (you can do so by submitting a key assignment transaction with your current Stride validator keys).

**What will happen to the validator set on Stride’s original (sovereign) mainnet chain? Will the sovereign chain continue to operate?**

The sovereign chain will not operate (all blocks will be produced by Hub validators). Stride validators will become “governors” and still can receive delegations. The expectation on governors is that they do NOT validate blocks, but they do the other functions of validators, including governance, running infrastructure, public education, business development, etc.

**Can I sync Stride mainnet without a snapshot?**

Yes, state sync is supported, but we’ve found snapshots as the most reliable method. Many members of the Stride community consistently upload high-quality snapshots. A couple to highlight are [Polkachu](https://polkachu.com/tendermint_snapshots/stride) and [BccNodes](https://bccnodes.com/m/stride/#snapshot).

[This connection script](https://github.com/Stride-Labs/mainnet/blob/main/mainnet/join_stride.sh) will automatically pull a recent snapshot and setup your node. 

**What should I set as the minimum commission rate?**

This is completely up to you, we’ve found most validators set 5%.

**What channel will launch communications be in?**

Discord channel dedicated to Stride’s launch (in the #cosmos-hub Discord).


# Section 5: System diagram
You can view a diagram of how the changeover works here: https://link.excalidraw.com/l/9UFOCMAZLAI/5EVLj0WJcwt
