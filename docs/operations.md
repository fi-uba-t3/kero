# Operations guide for KERO cluster

This guides provides useful information for cluster administrators on how to
operate and maintain cluster's nodes. It contains several standard operation
procedures for normal tasks (adding/removing _nodes_) as well as incident
troubleshooting.

## Adding/removing new hardware

TODO

## Replacing a faulty master node

When removing a master node follow the exact same procedure described for
removing any node. The only difference is that another master must be brought
up.

To bring up a new master you can either:
  - Add a new _node_ and install it as a master (following instructions of
    installation guide)
  - Choose an existing _node_ and run `upgrade-to-master` script. This script
    will drain the _node_ and re-install it as a master.

## Volume migration

Volumes are distributed upon all _nodes_ that provide storage. If one such a
node goes down the volumes will continue to operate but in a degraded fashion.
A healthy cluster supports up to three _nodes_ down before the possibility of
data loss. If a _node_ fails, migration of the volumes is needed to restore that
state.

To migrate volumes no service should be running, all volumes must be detached.
Make sure to run the migration during a maintenance window, shut down all user
desktops, LDAP instances and other services running in the cluster.

Then run:

`/usr/local/sbin/migrate-volumes`

Note: this script will take all the volumes with the old (degraded) brick set
(i.e. including the bricks from the node that are down) and migrate them into
the new set of bricks.

