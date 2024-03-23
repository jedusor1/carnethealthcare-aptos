#!/bin/sh

set -e

echo "##### Publishing module #####"

# Profile is the account you used to execute transaction
# Run "aptos init" to create the profile, then get the profile name from .aptos/config.yaml
PROFILE=0x9903da86deaaa17874f3fc9360a6a3cc589213bbab392c465a8883bb73547337

ADDR=0x$(aptos config show-profiles --profile=$PROFILE | grep 'account' | sed -n 's/.*"account": \"\(.*\)\".*/\1/p')

# You need to checkout to randomnet branch in aptos-core and build the aptos cli manually
# This is a temporary solution until we have a stable release randomnet cli
~/go/src/github.com/aptos-labs/aptos-core/target/debug/aptos move publish \
	--assume-yes \
  --profile $PROFILE \
  --named-addresses carnetrxaptos=$ADDR
