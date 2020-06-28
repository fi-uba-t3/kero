#! /bin/bash

set -exuo

export KERO_HOME="/vagrant" # Home for all our project
export DOMAIN_NAME="fiuba.com" # Domain name for LDAP
export LDAP_ADMIN_PASS="admin" # LDAP administrator password
echo 'KERO_HOME="/vagrant"' | sudo tee -a /etc/environment
echo 'DOMAIN_NAME="fiuba.com"' | sudo tee -a /etc/environment
echo 'LDAP_ADMIN_PASS="admin"' | sudo tee -a /etc/environment

$KERO_HOME/scripts/install-docker
$KERO_HOME/scripts/install-kubeadm
$KERO_HOME/scripts/install-etcdctl

if [[ "${NODE_ROLE}" == "master" ]]; then

    # If it is not the first master, we join the already existing cluster
    if [ -f $KERO_HOME/cache/join-master.sh ]; then
        echo "$(cat ${KERO_HOME}/cache/join-master.sh) --experimental-control-plane --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
    else
        # Otherwise, we create a new cluster.
        mkdir -p $KERO_HOME/cache

        # Generate and store a token for bootstrapping
        KUBEADM_TOKEN=$(kubeadm token generate)

        # The IP of the first node will be the service IP for the apiserver
        # service. TODO: replace this with a LB
        # It is replaced in the template from NODE_IP env var.
        envsubst < $KERO_HOME/kubeadm-config.yaml > /tmp/kubeadm-config.yaml
        sudo kubeadm init --config=/tmp/kubeadm-config.yaml \
            --experimental-upload-certs | tee $KERO_HOME/cache/kubeadm-init.log

        # Install network plugin
        sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f $KERO_HOME/services/kuberouter/kubeadm-kuberouter.yaml

        # Leave instructions to other masters and nodes on how to join the cluster.
        cat $KERO_HOME/cache/kubeadm-init.log | grep "experimental-control" -B2 > $KERO_HOME/cache/join-master.sh
        tail -2 $KERO_HOME/cache/kubeadm-init.log > $KERO_HOME/cache/join.sh

    fi

    # Install kubeconfig in vagrant's user home to use kubectl
    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

    $KERO_HOME/scripts/untaint-nodes
fi

if [[ "${NODE_ROLE}" == "slave" ]]; then
    echo "$(cat ${KERO_HOME}/cache/join.sh) --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
fi

# Changing kubelet nodeIP to properly show on kubectl get nodes
echo "KUBELET_EXTRA_ARGS=--node-ip ${NODE_IP}" >> /var/lib/kubelet/kubeadm-flags.env
sudo systemctl daemon-reload
sudo systemctl restart kubelet

$KERO_HOME/scripts/pull-images
sudo cp $(find $KERO_HOME/scripts -type f) /usr/local/sbin
sudo create-bricks
