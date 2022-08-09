#!/bin/bash
set -e
clear 

# you can always install this script with
# curl -L install.poolparty.stridelabs.co | sh

PURPLE='\033[0;35m'
BOLD="\033[1m"
BLUE='\033[1;34m'
ITALIC="\033[3m"
NC="\033[0m"
LOG_FILE="install.log"

STRIDE_COMMIT_HASH=4184e0c3852695895781a22c8723270bcc5b7f4e
STRIDE_FOLDER="$HOME/.stride"
LOG_PATH=$STRIDE_FOLDER/$LOG_FILE
TESTNET="poolparty"
INSTALL_FOLDER="$STRIDE_FOLDER/$TESTNET"
OLD_BINARY_VERSION=v1

printf "\n\n${BOLD}Welcome to the upgrade script for Stride's Testnet, ${PURPLE}PoolParty${NC}!\n\n"
printf "This script assumes you've been running Stride using the original setup script.\n"
printf "If you'd prefer to handle the upgrade manually, build from commit hash: $STRIDE_COMMIT_HASH\n\n"
pstr="Continue with the automated upgrade? [y/n] "
while true; do
    read -p "$(printf $PURPLE"$pstr"$NC)" yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) printf "Please answer yes or no.\n";;
    esac
done

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

printf "\nBefore we begin, let's make sure you have all the required dependencies installed.\n"
DEPENDENCIES=( "git" "go" )
missing_deps=false
for dep in ${DEPENDENCIES[@]}; do
    printf "\t%-8s" "$dep..."
    if [[ $(type $dep 2> /dev/null) ]]; then
        printf "$BLUE\xE2\x9C\x94$NC\n" # checkmark
    else
        missing_deps=true
        printf "$PURPLE\xE2\x9C\x97$NC\n" # X
    fi
done
if [[ $missing_deps = true ]]; then
    printf "\nPlease install all required dependencies and rerun this script!\n"
    exit 1
fi

printf "\nAwesome, you're all set.\n"

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

DEFAULT_STRIDE_BINARY="$HOME/go/bin/strided"
rstr="\nWhere is your stride binary? [default: $DEFAULT_STRIDE_BINARY] "
while true; do
    read -p "$(printf $PURPLE"$rstr"$NC)" STRIDE_BINARY
    if [ -z "$STRIDE_BINARY" ]; then
        STRIDE_BINARY=$DEFAULT_STRIDE_BINARY
    fi
    if [[ -f $STRIDE_BINARY ]]; then
        printf "$STRIDE_BINARY\n"
        break
    else
        printf "A stride binary does not exit at the specified location $STRIDE_BINARY." 
        continue
    fi
done

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

printf "\nThis script will replace your old binary with the new one, and rename your old binary to 'strided-$OLD_BINARY_VERSION'.\n"
pstr="\nContinue? [y/n] "
while true; do
    read -p "$(printf $PURPLE"$pstr"$NC)" yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) printf "Please answer yes or no.\n";;
    esac
done

date > $LOG_PATH

# Rename old binary with v1 suffix
BINARY_LOCATION="$(dirname "$STRIDE_BINARY")"
mv $STRIDE_BINARY $STRIDE_BINARY-$OLD_BINARY_VERSION

# Build new binary
printf "\nBuilding Stride..."
working_dir=$PWD
cd $INSTALL_FOLDER/stride
git pull origin main >> $LOG_PATH 2>&1
git checkout $STRIDE_COMMIT_HASH >> $LOG_PATH 2>&1
go build -mod=readonly -trimpath -o $BINARY_LOCATION ./... >> $LOG_PATH 2>&1
cd $working_dir
printf "Done \n"

# Copy binary to cosmovisor
cosmovisor_home=$STRIDE_FOLDER/cosmovisor
mkdir -p $cosmovisor_home/upgrades/v2/bin
cp $STRIDE_BINARY $cosmovisor_home/upgrades/v2/bin/

BLINE="\n${BLUE}============================================================================================${NC}\n"
printf $BLINE

printf "\nAnd that's it! Cosmovisor will now automatically switch to the new binary once an upgrade passes.\n"
printf "\nIn the meantime, make sure to issue any ${BOLD}strided${NC} commands with the old binary (${BOLD}strided-v1${NC}).\n"
printf "Once the upgrade has passed, you can go back to using ${BOLD}strided${NC} for all commands.\n"
printf "Or if you'd prefer, you can run commands with ${BOLD}$STRIDE_FOLDER/cosmosvisor/current/bin/strided${NC} which will always point to the current binary!\n\n"
