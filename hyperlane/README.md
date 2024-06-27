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

# Build the binary (it will be placed in `target/release/validator`)
cd rust 
cargo build --release --bin validator
```


### Configurations
There are many ways to optionally configure the validator using combinations of environment variables, CLI args, JSON files, etc. Below we recommend a setup that consists of an a JSON file and environment variables; however, if you prefer a different setup, I'd encourage you to review the hyperlane docs to find instructions on a setup that suits your needs.

Docs
  * https://docs.hyperlane.xyz/docs/operate/agent-config
  * https://docs.hyperlane.xyz/docs/operate/config-reference

#### Agent Config
Create an `agent-config.json` file and store it in a `config` directory at the same level that the binary is executed from. If you're using the dockerfile, this will be `app/config/agent-config.json`

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
      "domainId": 745,
      "chainId": "stride-1",
      "protocol": "cosmos",
      "canonicalAsset": "ustrd",
      "bech32Prefix": "stride",
      "rpcUrls": [
        {
          "http": "{RPC_URL}" // FILL THIS IN
        }
      ],
      "grpcUrls": [
        {
          "http": "{GRPC_URL}"  // FILL THIS IN
        }
      ],
      "grpcUrl": "{GRPC_URL}",  // FILL THIS IN
      "gasPrice": {
        "amount": "0.025",
        "denom": "ustrd"
      },
      "contractAddressBytes": 32,
      "index": {
        "from": 8686128,
        "chunk": 5
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
      "mailbox": "0x89945750e089d84581f194e1947a58480b335f18386ad4f761f05feebf5e2454",
      "validatorAnnounce": "0xf57d954bf3ddb5f1032a0e020a99e931215cf83ceb4de987c781488065aaae0d",
      "interchainGasPaymaster": "0x89f21bd61e9a38be1c8cff5a5b5c78433c22d554cb4247499ce4e761821685ed",
      "merkleTreeHook": "0x7ab4a8c3ba5371e34cd8d5dc584e0d924504fc21c3cbf41c3f64d436176bf007"
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
