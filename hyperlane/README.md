# Stride Hyperlane Validator Deployment Guide
### Validator Description
A hyperlane validator watches a chain's mailbox contract for message event emissions, then signs it for a relayer to pick up and forward it to the destination chain's mailbox.


### AWS Setup
* Basic Guide
    * https://docs.hyperlane.xyz/docs/guides/deploy-hyperlane-local-agents
* Create aws key (key name format should be `hyperlane-validator-{moniker}-stride-signer`)
    * https://docs.hyperlane.xyz/docs/operate/set-up-agent-keys#2-aws-kms
* Create s3 bucket (bucket name format should be `hyperlane-validator-{moniker}-signatures-stride`)
    * https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#2-create-an-s3-bucket
* Configure permissions
    * https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#3-configure-s3-bucket-permissions

### Running the Validator
The validator can be run through a provided docker file (see the [basic guide](https://docs.hyperlane.xyz/docs/guides/deploy-hyperlane-local-agents) above). Instructions are copied here for building the binary from source code

#### Source code
```bash
# Clone the repo
git clone git@github.com:hyperlane-xyz/hyperlane-monorepo.git
# install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# (apple silicon only) install rosetta 2
softwareupdate --install-rosetta --agree-to-license
```
To run the validator, configurations need to be provided as arguments when running the binary, through environment variables, and/or through an `agent-config.json` file.

Example of running the binary with some configs as arguments. It's recommended to use managed environment variables or configuration file(s) instead.
```bash
cargo run --release --bin validator -- \
    --db ./hyperlane_db_validator_<your_chain_name> \
    --originChainName <your_chain_name> \
    --checkpointSyncer.type localStorage \
    --checkpointSyncer.path $VALIDATOR_SIGNATURES_DIR \
    --validator.key <your_validator_key>
```


#### Configurations
* Docs
    * https://docs.hyperlane.xyz/docs/operate/agent-config
    * https://docs.hyperlane.xyz/docs/operate/config-reference

To re-iterate, there are [many ways](https://github.com/hyperlane-xyz/hyperlane-monorepo/tree/main/rust/config) the validator is configured. Some knowledge of chains are provided as [default configurations](https://github.com/hyperlane-xyz/hyperlane-monorepo/tree/main/rust/config) in the binary. Stride is not defined there, and will have to be defined explicitly.

Config files can be specified through an env var `CONFIG_FILES` as a comma separated list. Otherwise, environment variables can be [specified directly](https://docs.hyperlane.xyz/docs/operate/config-reference) following some patterns. Finally, configurations can be set through command lind argument as shown above (e.g. `--originChainName`).

Examples of tranforming configurations between the different input methods:

Config File (JSON)
```json5
# /path/to/config.json
{
  "db": "/path/to/dir",
  "chains": {
    "stride": { 
      "name": "stride",
      "domainId": 745,
      "grpcUrl": "http://stride-grpc.polkachu.com:12290"
    } 
  }
}

# Run with
CONFIG_FILES=/path/to/config.json ./validator
```
Command line arguments
```bash
./validator --db "path/to/dir" \
  --chains.stride.name stride \
  --chains.stride.domain 745 \
  --chains.stride.rpcurls.0.https "http://stride-grpc.polkachu.com:12290"
```
Environment Variables
```bash
HYP_DB="/path/to/dir"
HYP_CHAINS_STRIDE_NAME="stride"
HYP_CHAINS_STRIDE_DOMAIN=745
HYP_CHAINS_STRIDE_RPCURLS_0_HTTPS="http://stride-grpc.polkachu.com:12290"

# Run with
./validator
```

Hyperlane's [config reference](https://docs.hyperlane.xyz/docs/operate/config-reference) provides examples of translating between these three formats for each configuration. Note: `AWS_SECRET_ACCESS_KEY` and `AWS_SECRET_ACCESS_ID` must be specified as an environment variable.


* Necessary configurations as env vars
```bash
HYP_ORIGINCHAINNAME="stride"
HYP_DB="{path-to-db}"
# Not configured for us but marked as required in hyperlane docs
HYP_INTERVAL=5
HYP_CHAINS_STRIDE_DOMAIN=745
HYP_CHAINS_STRIDE_PROTOCOL="cosmos"
HYP_CHAINS_STRIDE_BECH32PREFIX="stride"
HYP_CHAINS_STRIDE_RPCURLS_0_HTTPS="{stride-rpc-endpoint}"
# Not documented, educated guess
HYP_CHAIN_STRIDE_GRPCURL="{stride-grpc-endpoint}"
HYP_CHAIN_STRIDE_CANONICAL_ASSET="ustrd"
HYP_CHAIN_STRIDE_CONTRACTADDRESSBYTES=32
HYP_CHAIN_STRIDE_GASPRICE_AMOUNT="0.025"
HYP_CHAIN_STRIDE_GASPRICE_DENOM="ustrd"

HYP_CHAIN_STRIDE_INDEX_FROM=3799834
HYP_CHAIN_STRIDE_INDEX_CHUNK=10000

HYP_CHAIN_STRIDE_BLOCKS_CONFIRMATION=1
HYP_CHAIN_STRIDE_BLOCKS_ESTIMATEBLOCKTIME=5
HYP_CHAIN_STRIDE_BLOCKS_REORD_PERIOD=1


# TODO: replace with prod contracts
HYP_CHAINS_STRIDE_MAILBOX="0xc9c2f63f96400eb1c83b9ad774cb1b06ab7f17af2d72fcdd6be8d4910f193749"
HYP_CHAINS_STRIDE_INTERCHAINGASPAYMASTER="0x42bd8a4b3b08062291975233ff1720a45ba43ceda0d9c865d2e07379dcad17b2"
HYP_CHAINS_STRIDE_VALIDATORANNOUNCE="0x83a96514493213f8c553639353da5a8738729b9c546f324c3b5a2b1d59474b0a"
HYP_CHAINS_STRIDE_MERKLETREEHOOK="0x86ca34a645c067cb7e847b2fc537b3823803f6860f4dd4779a997c30085a59dc"

HYP_CHAINS_STRIDE_SIGNER_TYPE="cosmosKey"
HYP_CHAINS_STRIDE_SIGNER_PREFIX="stride"
# This is the private key of a stride account (not to be confused with the AWS validator key that signs hyperlane messages)
# It is only responsible for submitting a "validator announce" message when registering the validator
# 1 STRD in this account should be sufficient
# To generate the private key from a cosmos address, run:
# >>> strided keys export {key-name} --unarmored-hex --unsafe
HYP_CHAINS_STRIDE_SIGNER_KEY=

HYP_VALIDATOR_TYPE="aws"
# AWS Region that's used for the AWS validator key
HYP_VALIDATOR_REGION=
# This the name of the AWS key that's used to sign hyperlane messages
# You can use the unique key ID or the alias (e.g. "alias/hyperlane-validator-{name}-stride-signer")
HYP_VALIDATOR_ID=

HYP_CHECKPOINTSYNCER_TYPE="s3"
# AWS Region that's used for the s3 bucket
HYP_CHECKPOINTSYNCER_REGION=
# This is the name of the AWS s3 bucket that stores signatures
# (e.g. "hyperlane-valdiator-{name}-signatures-stride)
HYP_CHECKPOINTSYNCER_BUCKET=

# These must be env vars
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

* Necessary configurations as `json` format (in `agent-config.json`)
```json
{
  "validator": {
    "type": "aws",
    "region": "",
    "id": ""
  },
  "checkpointsyncer": {
    "type": "s3",
    "region": "",
    "bucket": ""
  },
  "blocks": {
    "confirmations": 1,
    "estimateBlockTime": 5,
    "reorgPeriod": 1
  },
  "index": {
    "from": 3799834,
    "chunk": 10000
  },
  "chains": {
    "stride": {
      "signer": {
        "type": "comsosKey",
        "prefix": "stride",
        "key": "" // recommended to provide this as an env var due to its sensitivity (see above)
      },
      "name": "stride",
      "domainId": 745,
      "protocol": "cosmos",
      "rpcUrls": [
        {
          "http": "{stride-rpc-endpoint}"
        }
      ],
      "grpcUrl": "{stride-grpc-endpoint}",
      "canonicalAsset": "ustrd",
      "bech32Prefix": "stride",
      "gasPrice": {
        "amount": "0.025",
        "denom": "ustrd"
      },
      "contractAddressBytes": 32,
      // TODO: replace with prod contracts
      "mailbox": "0xc9c2f63f96400eb1c83b9ad774cb1b06ab7f17af2d72fcdd6be8d4910f193749",
      "validatorAnnounce": "0x83a96514493213f8c553639353da5a8738729b9c546f324c3b5a2b1d59474b0a",
      "interchainGasPaymaster": "0x42bd8a4b3b08062291975233ff1720a45ba43ceda0d9c865d2e07379dcad17b2",
      "merkleTreeHook": "0x86ca34a645c067cb7e847b2fc537b3823803f6860f4dd4779a997c30085a59dc"
    }
  }
}
```
Note: multiple formats for providing configurations can be used as long as all the necessary values are provided. 


### Monitoring
* Built-in grafana integration
    * https://docs.hyperlane.xyz/docs/operate/validators/monitoring-alerting