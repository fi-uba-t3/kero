#!/bin/bash

set -x


kubectl delete -n mattermost -f mattermost-installation.yaml
kubectl delete -n mattermost-operator -f mattermost-operator.yaml
kubectl delete -n minio-operator -f minio-operator.yaml
kubectl delete -n mysql-operator -f mysql-operator.yaml



