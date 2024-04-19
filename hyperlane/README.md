# Stride Hyperlane Validator Deployment Guide
## Validator Description
A hyperlane validator watches a chain's mailbox contract for message event emissions, then signs it for a relayer to pick up and forward it to the destination chain's mailbox.


## AWS Setup
* Basic Guide
    * https://docs.hyperlane.xyz/docs/guides/deploy-hyperlane-local-agents
* Create aws key (key name format should be `hyperlane-validator-{moniker}-stride-signer`)
    * https://docs.hyperlane.xyz/docs/operate/set-up-agent-keys#2-aws-kms
* Create s3 bucket (bucket name format should be `hyperlane-validator-{moniker}-signatures-stride`)
    * https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#2-create-an-s3-bucket
* Configure permissions
    * https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#3-configure-s3-bucket-permissions
* Use cast to determine your validator address
```bash
AWS_ACCESS_KEY_ID={access-key} AWS_SECRET_ACCESS_KEY={secret-access-key} AWS_DEFAULT_REGION={aws-region} AWS_KMS_KEY_ID=alias/hyperlane-validator-{moniker}-stride-signer cast wallet address --aws
```


## Running the Validator
### Binary Installation

#### From Docker
The preferred method is to run the validator through docker using the file: `gcr.io/abacus-labs-dev/hyperlane-agent:3bb4d87-20240129-164519`

#### From Source
Alternatively, you could build the binary from source: 
```bash
# Clone the repo
git clone git@github.com:hyperlane-xyz/hyperlane-monorepo.git
# install rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# (apple silicon only) install rosetta 2
softwareupdate --install-rosetta --agree-to-license
```


### Configurations
There are many ways to optionally configure the validator using combinations of environment variables, CLI args, JSON files, etc. Below we recommend a setup that consists of an a JSON file and environment variables; however, if you prefer a different setup, I'd encourage you to review the hyperlane docs to find instructions on a setup that suits your needs.

Docs
  * https://docs.hyperlane.xyz/docs/operate/agent-config
  * https://docs.hyperlane.xyz/docs/operate/config-reference

#### Agent Config
Create an `agent-config.json` file and store it in a `config` directory at the same level that the binary is executed from. If you're using the dockerfile, this will be `app/config/agent-config.json`

**NOTE: This has the current testnet values. We'll provide an updated file once the mainnet contracts are deployed.**

```js
// config/agent-config.json
{
  "originChainName": "stride",
  "validator": {
    "type": "aws"
  },
  "checkpointsyncer": {
    "type": "s3"
  },
  "interval": 5,
  "chains": {
    "stride": {
      "name": "stride",
      "domainId": 1651,
      "chainId": "stride-internal-1",
      "protocol": "cosmos",
      "canonicalAsset": "ustrd",
      "bech32Prefix": "stride",
      "rpcUrls": [
        {
          "http": "https://stride-validator.testnet-1.stridenet.co"
        }
      ],
      "grpcUrls": [
        {
          "http": "http://stride-direct.testnet-1.stridenet.co:9090"
        }
      ],
      "grpcUrl": "http://stride-direct.testnet-1.stridenet.co:9090",
      "gasPrice": {
        "amount": "0.025",
        "denom": "ustrd"
      },
      "contractAddressBytes": 32,
      "index": {
        "from": 3799834,
        "chunk": 10000
      },
      "blocks": {
        "confirmations": 1,
        "estimatedBlockTime": 5,
        "reorgPeriod": 1
      },
      "signer": {
        "type": "cosmosKey",
        "prefix": "stride"
      },
      "mailbox": "0xc9c2f63f96400eb1c83b9ad774cb1b06ab7f17af2d72fcdd6be8d4910f193749",
      "validatorAnnounce": "0x83a96514493213f8c553639353da5a8738729b9c546f324c3b5a2b1d59474b0a",
      "interchainGasPaymaster": "0x42bd8a4b3b08062291975233ff1720a45ba43ceda0d9c865d2e07379dcad17b2",
      "merkleTreeHook": "0x86ca34a645c067cb7e847b2fc537b3823803f6860f4dd4779a997c30085a59dc"
    }
  }
}
```

#### Environment Variables
In addition to the configuration above, provide the following as environment variables, using your preferred method of secret management for those that are sensitive.

```bash
# AWS Configuration
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# Path to validator database - this can be any folder, but the only requirement is 
# that the parent directory of the specified path must exist
# If using the dockerfile, this should be `/app/db` 
HYP_DB=

# This is the private key of a stride account (not to be confused with the AWS validator key that signs hyperlane messages)
# It is only responsible for submitting a "validator announce" message when registering the validator
# 1 STRD in this account should be sufficient
# To generate the private key from a cosmos address, run:
# >>> strided keys export {key-name} --unarmored-hex --unsafe
# Add an 0x prefix to the key generated from the command 
HYP_CHAINS_STRIDE_SIGNER_KEY=0x

# AWS Region that's used for the AWS validator key
HYP_VALIDATOR_REGION=
# This the name of the AWS key that's used to sign hyperlane messages
# You can use the unique key ID or the alias (e.g. "alias/hyperlane-validator-{name}-stride-signer")
HYP_VALIDATOR_ID=

# AWS Region that's used for the s3 bucket
HYP_CHECKPOINTSYNCER_REGION=
# This is the name of the AWS s3 bucket that stores signatures
# (e.g. "hyperlane-valdiator-{name}-signatures-stride")
HYP_CHECKPOINTSYNCER_BUCKET=
```

### Running
Finally, run the validator with:
```bash
./validator
```

### Monitoring
* Built-in grafana integration
    * https://docs.hyperlane.xyz/docs/operate/validators/monitoring-alerting