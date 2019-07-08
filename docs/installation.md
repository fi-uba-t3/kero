## KERO installation guide

This guide provides information on how to set up your KERO cluster and configure
it to be ready to serve users.

## Hardware requirements

## Installing the first machine

## Installing master nodes

## Installing slave nodes

## Setting up storage

To set up the storage provisioner for the first time, ssh into a KERO machine with kubectl support and run the script `deploy-glfs.sh` located under the `scripts` directory. 
This script takes the _number of replicas_ and the _number of bricks per node_ as arguments:
* _number of replicas_: Determines how many copies of every file are going to be distributed across the cluster.
* _number of bricks per node_: Determines how many glusterfs bricks are available to use on every node. By default, the number of bricks per node created on provision is 3.

An example usage of the script is:
```
node-1$ bash /vagrant/scripts/deploy-glfs.sh 3 3
```

## Configure LDAP and user credentials

