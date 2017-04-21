#!/bin/bash
#
# Opaali: get_sent_status
#

function usage {
    echo "usage: $1 access_token url" >/dev/stderr
    exit 1	
}

# parse arguments
if [ $# -ne 2 ]; then
	usage $0
else
    # parse arguments
    ACCESS_TOKEN=$1
    URL=$2
fi

# get status
curl -s -k "${URL}/deliveryInfos" --header "Accept: application/json" --header "Authorization: Bearer ${ACCESS_TOKEN}"

