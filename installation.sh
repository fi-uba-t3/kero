#! /bin/bash

set -ex

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
export KERO_HOME=$(pwd) # Home for all our project
echo "KERO_HOME=\"$KERO_HOME\"" | sudo tee -a /etc/environment

case $1 in
  first)
    echo "Install KERO first node. This process could take some time..."
    install_k8s

    mkdir -p $KERO_HOME/cache

    KUBEADM_TOKEN=$(kubeadm token generate)

    envsubst < $KERO_HOME/kubeadm-config.yaml > /tmp/kubeadm-config.yaml
    kubeadm config migrate --old-config /tmp/kubeadm-config.yaml --new-config /tmp/kubeadm-config18.yaml
    sudo kubeadm init --config=/tmp/kubeadm-config18.yaml --upload-certs | tee $KERO_HOME/cache/kubeadm-init.log

    # Install network plugin
    sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f $KERO_HOME/services/kuberouter/kubeadm-kuberouter.yaml

    # Leave instructions to other masters and nodes on how to join the cluster.
    cat $KERO_HOME/cache/kubeadm-init.log | grep "\-\-certificate-key" -B2 > $KERO_HOME/cache/join-master.sh
    tail -2 $KERO_HOME/cache/kubeadm-init.log > $KERO_HOME/cache/join.sh
    config_kubectl
    K8S_SVC_IP=$(sudo kubectl get svc | grep kubernetes | awk '{print $3}')
    sed -i -e "s/${NODE_IP}:6443/${K8S_SVC_IP}:443/g" $KERO_HOME/cache/*
    echo "Copy the /cache folder dammit!"
    ;;
  master)
    echo "Installing Kero master. This process could take some time..."
    install_k8s
    echo "$(cat ${KERO_HOME}/cache/join-master.sh) --control-plane --apiserver-advertise-address=${NODE_IP}" | sudo bash -s
    config_kubectl
    ;;
  slave)
    echo "Installing Kero slave. This process could take some time..."
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

sudo $KERO_HOME/scripts/pull-images
sudo cp $(find $KERO_HOME/scripts -type f) /usr/local/sbin
sudo create-bricks
