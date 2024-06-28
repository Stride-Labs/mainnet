# Forma Hyperlane Validator Deployment Guide
The forma validator setup will be identical to what you did for Stride, but with some differnet configurations.

## AWS Key
Feel free to use the same AWS keys as you did for Stride to make key management easier! If you choose not to do this, just make sure to update the respective AWS variables.

## S3 Bucket
You'll need a new bucket for the forma signatures. Follow the following guides to create it:
* Create s3 bucket (bucket name format should be `hyperlane-validator-{moniker}-signatures-forma`)
    * https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#2-create-an-s3-bucket
* Configure permissions
    * https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws#3-configure-s3-bucket-permissions

## Agent Config
```js
// config/agent-config.json
{
  "originChainName": "forma",
  "validator": {
    "type": "aws"
  },
  "checkpointsyncer": {
    "type": "s3"
  },
  "chains": {
    "forma": {
      "name": "forma",
      "displayName": "Forma",
      "displayNameShort": "Forma",
      "chainId": 984122,
      "domainId": 984122,
      "protocol": "ethereum",
      "rpcUrls": [
        {
          "http": "https://rpc.forma.art"
        }
      ],
      "nativeToken": {
        "name": "TIA",
        "symbol": "TIA",
        "decimals": 18
      },
      "blockExplorers": [
        {
          "name": "Forma Explorer",
          "url": "https://explorer.forma.art",
          "apiUrl": "https://explorer.forma.art/api",
          "family": "blockscout"
        }
      ],
      "staticMerkleRootMultisigIsmFactory": "0xD84b0e22B51c28b98d82d44f4047f597a5C3150e",
      "staticMessageIdMultisigIsmFactory": "0x10F6D2B39D33822f868fC6149ebb57543Fd66D13",
      "staticAggregationIsmFactory": "0x51b65b42C14a729fd587F011345FBE794aA3A651",
      "staticAggregationHookFactory": "0x4dd58237609F5C5cDA85e62f9912BEfa2d30f356",
      "domainRoutingIsmFactory": "0x6d2667249C24127A11009f8Af7A2b198a581B6C6",
      "interchainSecurityModule": "0xF77a8d7a8Cb0c07949A5417CfCb63F29b0fC8f04",
      "domainRoutingIsm": "0xF77a8d7a8Cb0c07949A5417CfCb63F29b0fC8f04",
      "merkleTreeHook": "0xB37bE3baC3Af0887c75EEa6F6D9394EBD1b1E2C9",
      "protocolFee": "0x26f21cA8e55Bd7b7759f2B6D76692E08D0d0d5F8",
      "testRecipient": "0xC0BF803f81a6A69e2551d203C54dEBFe68502965",
      "mailbox": "0xcb912D357c3f9aB7bdAD50B7D6Cb668896f17FE3",
      "proxyAdmin": "0xeD9A6DBa959Ab0E6c896E669840CBbda6ac17b52",
      "validatorAnnounce": "0x3434ecD3a6D3411A699A3e60AC8B3e6aFEBD40c3",
      "interchainGasPaymaster": "0x0000000000000000000000000000000000000000"
    }
  }
}
```

## Environment Variables
**Note: If you're using the same AWS key as you did on Stride, then the only variables that should change compared to the stride deployment are:**
  * `HYP_CHAINS_FORMA_SIGNER_KEY`
  * `HYP_CHECKPOINTSYNCER_BUCKET`
  * `HYP_CHECKPOINTSYNCER_REGION`

```bash
# AWS Configuration
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# Path to validator database - this can be any folder, but the only requirement is 
# that the parent directory of the specified path must exist
# If using the dockerfile, this should be `/app/db` 
HYP_DB=

# This is the private key of a forma account (not to be confused with the AWS validator key that signs hyperlane messages)
# It is only responsible for submitting a "validator announce" message when registering the validator
# 1 TIA in this account should be sufficient
# To generate the private key from a cosmos address, run:
# >>> cast wallet new-mnemonic -w 24
HYP_CHAINS_FORMA_SIGNER_KEY=0x

# AWS Region that's used for the AWS validator key
HYP_VALIDATOR_REGION=
# This the name of the AWS key that's used to sign hyperlane messages
# You can use the unique key ID or the alias (e.g. "alias/hyperlane-validator-{name}-forma-signer")
HYP_VALIDATOR_ID=

# AWS Region that's used for the s3 bucket
HYP_CHECKPOINTSYNCER_REGION=
# This is the name of the AWS s3 bucket that stores signatures
# (e.g. "hyperlane-valdiator-{name}-signatures-forma")
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
