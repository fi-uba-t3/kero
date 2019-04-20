#! /bin/bash

set -exuo

/vagrant/scripts/docker.sh
/vagrant/scripts/kubeadm.sh

if [[ $(hostname) == "node-1" ]]; then
    sudo kubeadm init --apiserver-advertise-address 10.0.0.1 --pod-network-cidr 10.1.0.0/16
    mkdir -p $HOME/.kube
    sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f /vagrant/manifests/kubeadm-kuberouter.yaml

    mkdir -p /vagrant/cache
    kubeadm token create --print-join-command > /vagrant/cache/join.sh

    ping google.com -c 10
fi

if [[ $(hostname) == "node-2" ]]; then
    sudo bash /vagrant/cache/join.sh
fi
