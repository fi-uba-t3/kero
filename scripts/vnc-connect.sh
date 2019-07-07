#!/bin/bash

set +x

function usage() {
    echo "Usage: $0 <desktop-spawner-IP> <userid>"
    exit 1
}

if [[ -z "$1" ]]; then
    usage
fi

if [[ -z "$2" ]]; then
    usage
fi


SPAWNER_IP=$1
VNC_USERNAME=$2

echo -n "Password for ${VNC_USERNAME}:"
read -sr VNC_PASS
echo

echo "{\"user\":\"${VNC_USERNAME}\", \"password\":\"${VNC_PASS}\"}" > cred.json
curl -X POST $SPAWNER_IP/desks -H "Content-type:application/json" -d @cred.json 
rm cred.json
echo
