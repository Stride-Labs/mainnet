#!/bin/bash
# This script requires gaiad to be available in the PATH.
# Usage: ./key_assignment_checker.sh <provider chain node> <consumer chain ID>
# Example: ./key_assignment_checker.sh https://cosmos-rpc.polkachu.com:443 stride-1 > assigned_keys.csv

# Credit to Dante Sanchez (dasanchez) from Hypha: https://gist.github.com/dasanchez/ab808d55803fa5ee593c6eb90d34d728#file-check_key_assignment-sh

node=$1
consumer_chain=$2
page_limit=2000


function process_page() {
    local page=$1
    # Collect all the validator consensus addresses for the provider chain
    local provider_addresses=($(curl -s $node/validators\?page=$page\&per_page=$page_limit | jq -r '.result.validators[].address'))
    # For each address, collect the consumer chain address.
    for i in "${provider_addresses[@]}"
    do
        local provider_address=$(gaiad keys parse $i --output json | jq -r '.formats[-2]')
        local consumer_address=$(gaiad q provider validator-consumer-key $consumer_chain $provider_address --node $node -o json | jq -r '.consumer_address')
        # Get moniker
        local public_key=$(curl -s $node/validators\?page=$page\&per_page=$page_limit | jq --arg ADDRESS "$i" -r '.result.validators[] | select(.address==$ADDRESS).pub_key.value')
        local moniker=$(gaiad q staking validators --node $node --limit $page_limit -o json | jq --arg PUBKEY "$public_key" -r  '.validators[] | select(.consensus_pubkey.key==$PUBKEY).description.moniker')
        # Get voting power
        local voting_power=$(curl -s $node/validators\?page=$page\&per_page=$page_limit | jq --arg ADDRESS "$i" -r '.result.validators[] | select(.address==$ADDRESS).voting_power')
        if [ -z "$consumer_address" ]; then
            echo "$moniker,no,$provider_address,,$voting_power"
        else
            echo "$moniker,yes,$provider_address,$consumer_address,$voting_power"
        fi
    done
}

# Call function for each page
process_page 1
process_page 2
