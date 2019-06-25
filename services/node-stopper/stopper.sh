#! /bin/bash

TIMES_NOT_READY_LIMIT=${TIMES_NOT_READY_LIMIT:-600}
SCRIPTS_DIR=${SCRIPTS_DIR:-/vagrant/scripts}

ALIVE_NODES=$(kubectl get nodes --no-headers | awk '{print $1}')

for NODE in ${ALIVE_NODES}; do

    ## This beautiful line parses the timestamp for the last Heartbeat of a particular
    ## node for condition Ready.
    LAST_READY_TIMESTAMP=$(kubectl get nodes ${NODE} -o json | jq '.status.conditions[]' | jq '"\(.type) \(.lastHeartbeatTime)"' | grep Ready | tr -d '"' | awk '{print $2}')

    DATE_LAST_READY=$(date +%s -d "${LAST_READY_TIMESTAMP}")
    DATE_NOW=$(date +%s)

    DIFF=$(( ${DATE_NOW}-${DATE_LAST_READY} ))
    echo "Last ready heartbeat for node ${NODE} was ${DIFF} seconds ago, limit is ${TIMES_NOT_READY_LIMIT} seconds"

    if [[ ${DIFF} -ge ${TIMES_NOT_READY_LIMIT} ]]; then
        echo "Node ${NODE} has been NotReady for too long"
        echo "Killing node ${NODE}"
        ${SCRIPTS_DIR}/destroy-node ${NODE}
    fi

done

