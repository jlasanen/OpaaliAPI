#!/bin/bash
#
# Opaali: create_basic_auth_string
#
if [ $# -ne 2 ]; then
    echo usage: $0 username password
else
    echo -n "$1:$2" | base64
fi
