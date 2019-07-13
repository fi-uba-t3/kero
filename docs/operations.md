# Operations guide for KERO cluster

This guides provides useful information for cluster administrators on how to operate and maintain cluster's nodes. It contains several standard operation procedures for normal tasks (adding/removing _nodes_) as well as incident troubleshooting.

## Removing a broken node

To remove a broken node from the cluster run the `destroy-node <broken-node>` command on any functional machine.

This will forcefully remove the node, and redeploy any service that was running there. The node can then be fixed and re-added with a clean install.

### Replacing a faulty master node

When removing a master node follow the exact same procedure described for removing any node. The only difference is that another master must be brought up.

To bring up a new master you can either:
  - Add a new _node_ and install it as a master (following the same instructions on the installation guide)
  - Choose an existing _node_ and run `upgrade-to-master` script. This script will drain the _node_ and re-install it as a master.

## Volume migration

Volumes are distributed upon all _nodes_ that provide storage. If any node goes down the volumes will continue to operate but in a degraded fashion.

A healthy cluster supports up to N _nodes_ down before the possibility of data loss, where N is the replication factor chosen when installing the KERO storage.

If any _node_ fails, migration of the volumes is needed to restore the healthy state.

To migrate volumes no service should be running, and all volumes must be detached.

Make sure to run the migration during a maintenance window, shut down all user desktops, LDAP instances and other services running on the cluster.

Then run:

`/usr/local/sbin/migrate-volumes`

Note: this script will take all the volumes with the old (degraded) brick set (i.e. including the bricks from the node that are down) and migrate them into
the new set of bricks.

