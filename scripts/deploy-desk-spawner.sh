#! /bin/bash

set +x

kubectl apply -f /vagrant/services/desktop-spawner/service.yaml

SPAWNER_STATUS=$(kubectl get pods | grep desk-spawner | awk '{print $3}') 
while [ $SPAWNER_STATUS != "Running" ]; do
    echo "Waiting for desktop-spawner deployment (status: ${SPAWNER_STATUS})"
    sleep 6
    SPAWNER_STATUS=$(kubectl get pods | grep desk-spawner | awk '{print $3}')
done

SPAWNER_IP=$(kubectl get svc --no-headers | grep "desk-spawner-svc" | awk '{print $3}')

echo "Connect to desktop-spawner on ${SPAWNER_IP}"
