# KERO installation guide

This guide provides information on how to set up your KERO cluster and configure it to be ready to serve users.

## Hardware requirements

## Installing the first machine

## Installing master nodes

## Installing slave nodes

## Setting up storage

To set up the storage provisioner for the first time, ssh into a KERO machine with kubectl support and run the script `deploy-glfs`.
 
This script takes the _number of replicas_ and the _number of bricks per node_ as arguments:

* _number of replicas_: Determines how many copies of every file are going to be distributed across the cluster.
* _number of bricks per node_: Determines how many glusterfs bricks are available to use on every node. By default, the number of bricks per node created on provision is 3.

An example usage of the script is:
```
node-1$ bash /vagrant/scripts/deploy-glfs.sh 3 3
```

## Configuring LDAP and user credentials

With your shared storage already setted, you can now deploy the users administration service based on OpenLDAP. In order to do that, simply run the `deploy-ldap` command on any machine with kubectl support.

The `deploy-ldap` script can optionally take the desired LDAP server IP as argument (it defaults to 10.96.100.100).

Once deployed, you will be able to visit the admin panel of the LDAP server on the IP informed by the script. The homepage should be like the following:

![](./img/ldap_homepage.png)

To manage your KERO cluster users, first click _login_ on the admin panel.

![](./img/ldap_login.png)

After entering your administrator full DN (the one you specified during the KERO installation) and password, you should be successfully logged in into the admin panel.

![](./img/ldap_login_success.png)

By clicking the _import_ icon, you will be able to import new LDAP entries by either specifying some .ldif file on your machine or pasting its contents

![](./img/ldap_import.png)

After importing your data, click on _Proceed_.

![](./img/ldap_import_with_ldif.png)

If no errors where present on the .ldif file, the new entries should all be created successfully:

![](./img/ldap_import_success.png)

Alternatively, you can manually add new LDAP entries by clicking on the _Create new entry here_ button on the left menu.

![](./img/ldap_create_entry.png)

For instance, for adding a new user choose _Generic: User Account_. A form like the following should appear:

![](./img/ldap_create_user_form.png)

After completing the whole form with your new user information, select _Create Object_. Please note that you will have to provide your final users their new user ID and password, so do not lose them.

![](./img/ldap_create_user_form_completed.png)

Review the new user information and click on _Commit_:

![](./img/ldap_create_user_confirm.png)

For viewing or editing the newly created used, simply click it on the left menu tree.

![](./img/ldap_view_edit_user.png)

If you want to delete some user, after selecting it on the left menu tree click on _Delete this entry_. A confirmation box will appear. Click on _Delete_.

![](./img/ldap_delete_user_confirm.png)

A success message should appear and the user should be deleted.

![](./img/ldap_delete_user_success.png)

## Monitoring your cluster 
