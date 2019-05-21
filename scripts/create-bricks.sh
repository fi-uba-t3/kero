#!/bin/bash
set -x

# Run only on storage nodes
mkdir -p /etc/kubernetes/brick
mkfs.ext4 /dev/sdc
mount /dev/sdc /etc/kubernetes/brick
