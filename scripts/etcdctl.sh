#! /bin/bash

set -x

## Download and instal etcdctl
ETCD_VER=v3.3.13
DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

## Remove previous downloads
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download && mkdir -p /tmp/etcd-download

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

mv /tmp/etcd-download/etcdctl /usr/local/sbin/etcdctl
rm -rf /tmp/etcd-download

## Source this file to have the configuration for etcdctl
cat >/etc/profile.d/etcdctl.sh <<"EOF"
#! /bin/bash

export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/ca.key
export ETCDCTL_ENDPOINTS=https://10.0.0.2:2379,https://10.0.0.3:2379
export ETCDCTL_API=3

alias etcdctl="etcdctl --insecure-skip-tls-verify"
EOF
