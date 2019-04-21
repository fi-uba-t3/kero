#! /bin/bash

set -exuo

/vagrant/scripts/docker.sh
/vagrant/scripts/kubeadm.sh


if [[ "${NODE_ROLE}" == "master" ]]; then

    # If it is not the first master, we join the already existing cluster
    if [ -f /vagrant/cache/join-master.sh ]; then
        echo "$(cat /vagrant/cache/join-master.sh) --experimental-control-plane --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
    else
        # Otherwise, we create a new cluster.
        mkdir -p /vagrant/cache

        # The IP of the first node will be the service IP for the apiserver
        # service. TODO: replace this with a LB
        sed -e "s/{{NODE_IP}}/${NODE_IP}/" /vagrant/kubeadm-config.yaml > /tmp/kubeadm-config.yaml
        sudo kubeadm init --config=/tmp/kubeadm-config.yaml \
            --experimental-upload-certs | tee /vagrant/cache/kubeadm-init.log

        # Install network plugin
        sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f /vagrant/manifests/kubeadm-kuberouter.yaml

        # Leave instructions to other masters and nodes on how to join the cluster.
        cat /vagrant/cache/kubeadm-init.log | grep "experimental-control" -B2 > /vagrant/cache/join-master.sh
        kubeadm token create --print-join-command > /vagrant/cache/join.sh

    fi

    # Install kubeconfig in vagrant's user home to use kubectl
    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config
fi

if [[ "${NODE_ROLE}" == "slave" ]]; then
    echo "$(cat /vagrant/cache/join.sh) --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
fi

# Changing kubelet nodeIP to properly show on kubectl get nodes
echo "KUBELET_EXTRA_ARGS=--node-ip ${NODE_IP}" >> /var/lib/kubelet/kubeadm-flags.env
sudo systemctl daemon-reload
sudo systemctl restart kubelet
