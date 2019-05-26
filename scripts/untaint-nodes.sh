#! /bin/bash

STORAGE_NODES=$(kubectl get nodes --no-headers | awk '{print $1}')
for node in $STORAGE_NODES; do
    kubectl taint nodes $node node-role.kubernetes.io/master- || true
done
