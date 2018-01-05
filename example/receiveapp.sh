#!/bin/bash
#
# receiveapp.sh - an application for polling incoming text messages using Opaali API
#
# This is an example of using Opaali API from a shell script
# to poll for received MO SMS messages
#
# This is an example and not intended for production use as such
#
# Author: jlasanen
#

# resource Id for receive service
RESID='291ae4cc-51b5-48b9-9b8f-4d8e88a7c68a'

# file where your credentials are stored
CREDENTIALS_FILE=.opaalicredentials_ro

# read service specific credentials from a file
# containing the following two entries
# (uncomment and replace with your own credentials,
#  try to keep the file in a safe place so that your
#  credentials won't leak for others to use)
#applicationUserName="b535b0c5e5ae815cea82db6b3b25095a"
#applicationPassword='1%AMCC?w'
function read_credentials {
    #param 1: filename

    source "$1"
}


# print usage instructions and exit
function usage {
    #param 1: commandName

    echo "Usage: $1 " >/dev/stderr
    echo "       this application polls for received MO messages from Opaali and writes the senderAddress and message to stdout" >/dev/stderr
    exit 1
}

# print error message and exit
function error_exit {
    #param 1: commandName
    #param 2: msg
    #param 3: param

    echo "$1: $2 $3" >/dev/stderr
    usage "$1"
}



# authenticate and get access_token
function authenticate {
    #param 1: Application User Name
    #param 2: Application Password
    #global: access_token 
    #global: emsg
    
    # construct basic_auth string by combining username and password separated
    # with a colon and base64-encoding it all
    basic_auth=$(echo -n "$1:$2" |base64)
    #echo $basic_auth 
    # call Opaali API and capture the interesting parts from the output
    local output=$(curl -k -s -d grant_type=client_credentials https://api.opaali.telia.fi/autho4api/v1/token --header "Content-Type:application/x-www-form-urlencoded" --header "Authorization: Basic $basic_auth" | grep -E 'access_token|error')
    #echo $output 
    # post processing: check for success or failure
    # we could test the return value, but choose to check the output only
    
    # try grabbing access_token from the output
    access_token=$(echo "$output" | grep access_token | cut -d\: -f2 | tr -d "\", ")
    if [[ -z "$access_token" ]]; then
        # access_token is empty so something went wrong
        local error=$(echo "$output" | grep 'error' )
        if [[ -n "$error" ]]; then
            # we got error message from Opaali API
            emsg=$(echo "$error" | cut -d\: -f2)
        else
            # something went wrong with curl (now testing return value would have beeen useful...)
            emsg="unknown error"
        fi
        return 1
    fi
    return 0
}


# main program
function main {
    #params: all command line parameters
    #parse_arguments "$@"
    
    read_credentials "${CREDENTIALS_FILE}"
    
    emsg=""
    authenticate "$applicationUserName" "$applicationPassword"
    
    if [[ "$?" -ne 0 ]]; then
        error_exit "$0" "$emsg"
    fi

    # enter main loop
    main_loop    
}


# access_token is kept in a global variable
access_token=

# polling interval between checking incoming messages
INTERVAL=30

# loop checking for new messages 
function main_loop {
    #params: none
    #global: access_token 
    #global: emsg
    #global: RESID
    #global: INTERVAL

    while [[ true ]] 
    do
        # check for incoming messages
        check_incoming $RESID
        if [[ -z $access_token ]] 
        then
            #echo no access token, get one
            emsg=""
            authenticate "$applicationUserName" "$applicationPassword"
        fi
        # wait, do not call Opaali API too often!
        sleep $INTERVAL
    done
}

# call Opaali API and get possibly available new MO messages
function check_incoming {
    #params: resource Id for receive service
    #global: access_token 
    #global: emsg
    #global: RESID

    # call Opaali API and capture the interesting parts from the output
    local output=$(curl -s -k -d "{\"inboundMessageRetrieveAndDeleteRequest\":{\"retrievalOrder\":\"OldestFirst\",\"useAttachmentURLs\":\"true\"}}" https://api.sonera.fi/production/messaging/v1/inbound/registrations/$1/messages/retrieveAndDeleteMessages --header "Content-Type: application/json" --header "Accept: application/json" --header "Authorization: Bearer $access_token" | grep -e '"message"' -e '"error"' -e '"senderAddress"')
    # check output for senderAddress
    local msisdn=$(echo "$output" | grep '"senderAddress"' | cut -d: -f2- | cut -d: -f2 | tr -d '",')
    # check output for message data
    local data=$(echo "$output" | grep '"message"' | cut -d: -f2- | xargs -n 1)
    if [[ -n "$data" ]]; then
        # we may get multiple messages in one call so lets store msisdn and data into arrays
        mapfile -t msisdns < <(echo "$msisdn")
        mapfile -t datas < <(echo "$data")
        # get the size of array(s) and loop outputting matching msisdn and message
        count=${#msisdns[@]}
        for ((index=0; index < ${#msisdns[@]}; index++)); do
            echo "${msisdns[index]} \"${datas[index]}\""
        done
    fi
    # check for errors
    local error=$(echo "$output" | grep '"error"' )
    if [[ -n "$error" ]]; then
        # we got error message from Opaali API
        emsg=$(echo "$error" | cut -d\: -f2 | xargs -n 1)
        if [[ "$emsg" = "invalid_token" ]] 
        then 
            # access_token has expired, by setting it to empty string we will trigger reauthentication
            access_token=
        fi
    fi

}

# call main program
main "$@"

# end of script
