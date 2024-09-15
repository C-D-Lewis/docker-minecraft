#!/bin/bash

set -eu

DNS_SUBDOMAIN=$1

# AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required with Route53 update permissions
echo "Using credentials $AWS_ACCESS_KEY_ID / $AWS_SECRET_ACCESS_KEY"

# Name of the DNS zone (domain)
export HOSTED_ZONE_NAME="chrislewis.me.uk"
# Prefix to use in the public record
export RECORD_NAME_PREFIX="$DNS_SUBDOMAIN"

node scripts/lib/update-dns.js
