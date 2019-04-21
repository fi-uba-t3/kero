#! /bin/bash

set -exuo

/vagrant/scripts/docker.sh
/vagrant/scripts/kubeadm.sh

if [[ $(hostname) == "node-1" ]]; then
    sudo kubeadm init --apiserver-advertise-address 10.0.0.2 --pod-network-cidr 10.1.0.0/16
    mkdir -p $HOME/.kube
    sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f /vagrant/manifests/kubeadm-kuberouter.yaml

    mkdir -p /vagrant/cache
    kubeadm token create --print-join-command > /vagrant/cache/join.sh

    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

    echo "KUBELET_EXTRA_ARGS=--node-ip 10.0.0.2" >> /var/lib/kubelet/kubeadm-flags.env
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
fi

if [[ $(hostname) == "node-2" ]]; then
    echo "$(cat /vagrant/cache/join.sh) --apiserver-advertise-address=10.0.0.3" | sudo bash -s
    echo "KUBELET_EXTRA_ARGS=--node-ip 10.0.0.3" >> /var/lib/kubelet/kubeadm-flags.env
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
fi
