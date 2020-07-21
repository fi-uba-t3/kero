#!/bin/bash

set -x

kubectl create ns mysql-operator
kubectl create ns minio-operator
kubectl create ns mattermost-operator
kubectl create ns mattermost

kubectl apply -n mysql-operator -f mysql-operator.yaml
kubectl apply -n minio-operator -f minio-operator.yaml
kubectl apply -n mattermost-operator -f mattermost-operator.yaml
kubectl apply -n mattermost -f mattermost-installation.yaml
kubectl delete -n mattermost pvc kero-chat1-minio-kero-chat1-minio-0
kubectl apply -n mattermost -f volumes.yaml