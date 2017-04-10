#!/bin/bash
#
# Opaali: send_text_message
#

function usage {
    echo "usage: $1 [-u|-d] access_token from=<sendernumber> to=<recipientnumber> [sendername=<sendername>] msg=<messagetext>" >/dev/stderr
    echo "       options: " >/dev/stderr
    echo "                -u : return resourceURL only" >/dev/stderr
    echo "                -d : print debug output" >/dev/stderr
    exit 1    
}

# parse arguments
if [ $# -le 3 ]; then
    usage $0
else
    # parse arguments
    for i in "$@"
    do
        case $1 in
            -u)
            URLONLY=1
            shift
            ;;
            -d)
            DEBUG=1
            shift
            ;;
            *)
            break
            ;;
        esac
    done
    ACCESS_TOKEN=$1
    shift
    for i in "$@"
    do
        case $1 in
            from=*)
            FROM="${i#*=}"
            shift
            ;;
            to=*)
            TO="${i#*=}"
            shift
            ;;
            sendername=*)
            SENDERNAME="${i#*=}"
            shift
            ;;
            msg=*)
            MSG="${i#*=}"
            shift
            ;;
            -u)
            URLONLY=1
            shift
            ;;
            -d)
            DEBUG=1
            shift
            ;;
            *)
            if [ -z ${TEXT} ]; then
                MSG=${i}
            else
                usage $0
            fi
            ;;
        esac
    done

    if [[ -z ${TO}  || -z ${FROM} || -z ${MSG} ]]; then
        usage $0
    fi

    if [ ! -z ${DEBUG} ]; then
        echo "access_token=${ACCESS_TOKEN}"
        echo "from = ${FROM}"
        echo "to = ${TO}"
        echo "sendername = ${SENDERNAME}"
        echo "message = ${MSG}"
    fi
    
    if [ ! -z ${SENDERNAME} ]; then
        SENDERNAMESTRING=",\"senderName\":\"${SENDERNAME}\""
    else
        SENDERNAMESTRING=""
    fi
fi

#urlencode + and :
sender=`echo -n ${FROM} | sed -e s/\+/%2B/g -e s/\:/%3A/g`

# send
if [ -z $URLONLY ]; then
    curl -s -k -d "{\"outboundMessageRequest\":{\"address\":[\"${TO}\"],\"senderAddress\":\"${FROM}\",\"outboundSMSTextMessage\":{\"message\": \"${MSG}\"}${SENDERNAMESTRING}}}"  https://api.sonera.fi/production/messaging/v1/outbound/${sender}/requests --header "Content-Type:application/json" --header "Authorization: Bearer ${ACCESS_TOKEN}"
    status=$?
else
    response=`curl -s -k -d "{\"outboundMessageRequest\":{\"address\":[\"${TO}\"],\"senderAddress\":\"${FROM}\",\"outboundSMSTextMessage\":{\"message\": \"${MSG}\"}${SENDERNAMESTRING}}}"  https://api.sonera.fi/production/messaging/v1/outbound/${sender}/requests --header "Content-Type:application/json" --header "Authorization: Bearer ${ACCESS_TOKEN}"`
    status=$?
    responseURL=`echo -e $response | grep resourceURL | cut -d\: -f3- | tr -d "\" \n}"`
    if [ -z $responseURL ]; then
        echo $response
        exit 1
    else
        echo $responseURL
        exit $status
    fi
fi
