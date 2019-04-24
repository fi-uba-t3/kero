# Testing environment configuration

Scripts and configuration files needed to bring up a cluster of virtual
machines. Use `config.yaml` to decide how many machines will be brought up and
modify `provision.sh` to define what is going to be installed in them.

## Pre-requisites

You will need:
- [Vagrant](https://www.vagrantup.com/downloads.html) (tested with 2.2.4)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (tested with 5.2.26 r128414)
- Vagrant vbguest plugin (can be installed with `vagrant plugin install vagrant-vbguest`)

## Starting up the cluster

Run `vagrant up` to ~~make your computer catch fire~~ bring up the cluster. The first time it will create the VMs
one by one. Take into account that it may take a while since it needs to
download the base boxes (os.image in `config.yaml`) and run the `provision.sh`
script which also get some things from the apt repositories.

All the VMs will start up and run `provision.sh`, with the `NODE_ROLE` and
`NODE_IP` environment variables set up appropriately. More environment variables
can be defined and pass to the script by adding them in `config.yaml` and
reading them in `Vagrantfile`.

## Accesing the cluster

Run `vagrant status` to get see which virtual machines are currently running.

Run `vagrant ssh node-x` to ssh into the machine x.

**IMPORTANT**: Vagrant virtual machines share with the host the directory where the Vagrantfile is. This direcotry is mounted in `/vagrant` on every VM.

Run `vagrant provision` to re-run provisioning scripts on all VMs. Be aware that
the VM is not formatted or deleted, so any thing that is already running may
interfere and cause the script to fail.

Run `vagrant halt` to stop all VMs (in this Vagrantfile). You can use `vagrant
hatl node-x` to stop a specific machine. The same works for `vagrant up` and
`vagrant provision`

To create a tunnel from the host machine to a VM (e.g. to access a service
through a browser), first run `vagrant ssh-config`. This will output for every
VM on which port (in the host) it is listening for ssh, and where is the private
key to log in. For example:

```
Host node-1
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/jfresia/fiuba/taller/.vagrant/machines/node-1/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

With this information run the following command, which will ssh into the machine
and create a tunnel through `<host-port>` to `<target-ip>:<target-port>` on the
specified machine.

```
ssh -o StrictHostKeyChecking=no -i <IdentityFile> -L <host-port>:<target-ip>:<target-port> -p <vm-ssh-port> vagrant@localhost
```

Run `vagrant destroy` to fully wipe all VMs for good.

