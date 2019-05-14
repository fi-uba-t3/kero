#!/bin/bash
# Run only on storage nodes

sudo su
mkdir -p /etc/kubernetes/brick
mkfs.ext4 /dev/sdc
mount /dev/sdc /etc/kubernetes/brick
