# Echos Hyperlane Validator Deployment Guide

The echos validator setup will be identical to what you did for Stride, but with some different configurations.

## AWS Key

Feel free to use the same AWS keys as you did for Stride to make key management easier! If you choose not to do this, just make sure to update the respective AWS variables.

## S3 Bucket

You'll need a new bucket for the forma signatures. Follow the following guides to create it:

- Create s3 bucket (bucket name format should be `hyperlane-validator-{moniker}-signatures-echos`)
  - https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#2-create-an-s3-bucket
- Configure permissions
  - https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#3-configure-s3-bucket-permissions

## Agent Config

```js
// config/agent-config.json
{
  "originChainName": "echos",
  "validator": {
    "type": "aws"
  },
  "checkpointsyncer": {
    "type": "s3"
  },
  "chains": {
    "echos": {
      "name": "echos",
      "displayName": "Echos",
      "displayNameShort": "Echos",
      "chainId": 4321,
      "domainId": 4321,
      "protocol": "ethereum",
      "rpcUrls": [
        {
          "http": "https://rpc-echos-mainnet-0.t.conduit.xyz"
        }
      ],
      "nativeToken": {
        "name": "USDC",
        "symbol": "USDC",
        "decimals": 18
      },
      "blockExplorers": [
        {
          "name": "Echos Explorer",
          "url": "https://explorer.echos.fun",
          "apiUrl": "https://explorer.echos.fun/api",
          "family": "blockscout"
        }
      ],
      "staticMerkleRootMultisigIsmFactory": "0x54f815Ea3fb27802a0A6648D7fa17E246080003e",
      "staticMessageIdMultisigIsmFactory": "0xC54327035f6aD1c828cF2B92AFabEf28CF3c937e",
      "staticAggregationIsmFactory": "0xd4103b43ADb2214951cAa2B190ba1Ba1bF462F0A",
      "staticAggregationHookFactory": "0x577d681F3BF0eF4bed349Cc718f584221798392D",
      "domainRoutingIsmFactory": "0x2F91D969E0a1318A36E0c4f9e180Aa9aA9713904",
      "interchainSecurityModule": "0x1D13e24Bb2Dbc8792A9d6Ec51Ef91121247f1926",
      "merkleTreeHook": "0xB04667c75e01aEea9e742eF50CDe6f30C9Ce8136",
      "protocolFee": "0x56f57BCfFC6e285552778EC4ce535513E826Bc9c",
      "testRecipient": "0xa2d56aA1Fd4cbA1b745c729B47eD2aCF945450b1",
      "mailbox": "0x2cA13C25A48B5A98c5AD47808Efa983D29543a9a",
      "proxyAdmin": "0xeD9A6DBa959Ab0E6c896E669840CBbda6ac17b52",
      "validatorAnnounce": "0x294139274Fd47a69Cbb7F3D0c712BdcDc718EB17",
      "interchainGasPaymaster": "0x26006d6E9931320DE9A7C80629F3bE5c1Adcd3FD"
    }
  }
}
```

## Environment Variables

**Note: If you're using the same AWS key as you did on Stride, then the only variables that should change compared to the stride deployment are:**

- `HYP_CHAINS_FORMA_SIGNER_KEY`
- `HYP_CHECKPOINTSYNCER_BUCKET`
- `HYP_CHECKPOINTSYNCER_REGION`

```bash
# AWS Configuration
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# Path to validator database - this can be any folder, but the only requirement is
# that the parent directory of the specified path must exist
# If using the dockerfile, this should be `/app/db`
HYP_DB=

# This is the private key of a echos account (not to be confused with the AWS validator key that signs hyperlane messages)
# It is only responsible for submitting a "validator announce" message when registering the validator
# 1 USDC in this account should be sufficient
# To generate the private key from a cosmos address, run:
# >>> cast wallet new-mnemonic -w 24
HYP_CHAINS_ECHOS_SIGNER_KEY=0x

# AWS Region that's used for the AWS validator key
HYP_VALIDATOR_REGION=
# This the name of the AWS key that's used to sign hyperlane messages
# You can use the unique key ID or the alias (e.g. "alias/hyperlane-validator-{name}-echos-signer")
HYP_VALIDATOR_ID=

# AWS Region that's used for the s3 bucket
HYP_CHECKPOINTSYNCER_REGION=
# This is the name of the AWS s3 bucket that stores signatures
# (e.g. "hyperlane-valdiator-{name}-signatures-echos")
HYP_CHECKPOINTSYNCER_BUCKET=
```

### Running

Finally, run the validator with:

```bash
./validator
```

### Monitoring

- Built-in grafana integration
  - https://docs.hyperlane.xyz/docs/operate/validators/monitoring-alerting
