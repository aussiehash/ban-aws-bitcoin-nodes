#!/bin/bash

# This checks if you have jq installed
command -v jq >/dev/null 2>&1 || { echo >&2 "Please install \"jq\" first. Aborting."; exit 1; }

# Adjust if necessary
IP_RANGES_FILE='/tmp/amazon-ip-ranges.json'
CLIENT=/usr/local/bin/bitcoin-cli

# Ban Time in seconds, 2592000 = 30 days
BAN_TIME="2592000"

# Get list of Amazon IP Ranges http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html
wget -qO- https://ip-ranges.amazonaws.com/ip-ranges.json -O $IP_RANGES_FILE

# Extract IPV4 and IPV6 ranges
AWS_IP_RANGES=`jq -r '.prefixes[].ip_prefix, .ipv6_prefixes[].ipv6_prefix' $IP_RANGES_FILE`

# Ban extracted ranges with bicoin-cli using BAN_TIME
for RANGE in $AWS_IP_RANGES; do
  $($CLIENT setban $RANGE "add" ${BAN_TIME})
done

# Remove tmp file
rm $IP_RANGES_FILE
