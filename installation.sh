#! /bin/bash

set -ex

export KERO_HOME="/vagrant" # Home for all our project
export DOMAIN_NAME="fiuba.com" # Domain name for LDAP
export LDAP_ADMIN_PASS="admin" # LDAP administrator password
echo 'KERO_HOME="/vagrant"' | sudo tee -a /etc/environment
echo 'DOMAIN_NAME="fiuba.com"' | sudo tee -a /etc/environment
echo 'LDAP_ADMIN_PASS="admin"' | sudo tee -a /etc/environment

function install_k8s {
  sudo $KERO_HOME/scripts/install-docker
  sudo $KERO_HOME/scripts/install-kubeadm
  sudo $KERO_HOME/scripts/install-etcdctl
}

function config_kubectl {
  # Install kubeconfig in vagrant's user home to use kubectl
  ADMIN_USER=$(whoami)
  USER_HOME=$(eval echo ~$ADMIN_USER)
  sudo --user=${ADMIN_USER} mkdir -p ${USER_HOME}/.kube
  sudo cp -i /etc/kubernetes/admin.conf ${USER_HOME}/.kube/config
  sudo chown $(id -u ${ADMIN_USER}):$(id -g ${ADMIN_USER}) ${USER_HOME}/.kube/config
  sudo cp ${USER_HOME}/.kube/config ${KERO_HOME}/cache/
}


if [[ -z $1 ]]; then
  echo "Usage: $0 [first | master | slave] <IP>"
  exit 1
fi

if [[ -z $2 ]]; then
  echo "Usage: $0 [first | master | slave] <IP>"
  exit 1
fi

export NODE_IP=$2

case $1 in
  first)
    echo "first"
    install_k8s
    
    mkdir -p $KERO_HOME/cache

    KUBEADM_TOKEN=$(kubeadm token generate)
    envsubst < $KERO_HOME/kubeadm-config.yaml > /tmp/kubeadm-config.yaml
    sudo kubeadm init --config=/tmp/kubeadm-config.yaml --experimental-upload-certs | tee $KERO_HOME/cache/kubeadm-init.log

    # Install network plugin 
    sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f $KERO_HOME/services/kuberouter/kubeadm-kuberouter.yaml

    # Leave instructions to other masters and nodes on how to join the cluster.
    cat $KERO_HOME/cache/kubeadm-init.log | grep "experimental-control" -B2 > $KERO_HOME/cache/join-master.sh
    tail -2 $KERO_HOME/cache/kubeadm-init.log > $KERO_HOME/cache/join.sh 
    config_kubectl
    K8S_SVC_IP=$(sudo kubectl get svc | grep kubernetes | awk '{print $3}')
    sed -i -e "s/${NODE_IP}:6443/${K8S_SVC_IP}:443/g" $KERO_HOME/cache/*
    echo "Copy the /cache folder dammit!"
    ;;
  master)
    echo "master"
    install_k8s
    echo "$(cat ${KERO_HOME}/cache/join-master.sh) --experimental-control-plane --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
    config_kubectl
    ;;
  slave)
    echo "slave"
    install_k8s 
    echo "$(cat ${KERO_HOME}/cache/join.sh) --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
    
    ADMIN_USER=$(whoami)
    USER_HOME=$(eval echo ~$ADMIN_USER)
    mkdir ${USER_HOME}/.kube
    cp ${KERO_HOME}/cache/config ${USER_HOME}/.kube/
    ;;
  *)
    echo "Usage: $0 [first | master | slave]"
    exit 1
    ;;
esac

echo "KUBELET_EXTRA_ARGS=--node-ip ${NODE_IP}" | sudo tee -a /var/lib/kubelet/kubeadm-flags.env
sudo systemctl daemon-reload
sudo systemctl restart kubelet

#$KERO_HOME/scripts/pull-images
sudo cp $(find $KERO_HOME/scripts -type f) /usr/local/sbin
sudo create-bricks
