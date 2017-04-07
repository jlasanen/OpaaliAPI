#!/bin/bash
#
# Opaali: get_access_token
#
if [ $# -ne 1 ]; then
    echo usage: $0 basic_auth_string
else
    curl -s -k -d grant_type=client_credentials  https://api.sonera.fi/autho4api/v1/token --header "Content-Type:application/x-www-form-urlencoded" --header "Authorization: Basic $1" | grep access_token | cut -d\: -f2 | tr -d "\", "
fi
