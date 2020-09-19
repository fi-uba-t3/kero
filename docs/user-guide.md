# User guide to KERO

This guide is aimed for KERO final users and provides information on how to access and use the different services provided.

## First steps

### Configuring your local dns

Add the following lines to your `/etc/hosts` files

```
external-ip kero.kero-admin.io
external-ip kero.ldap-admin.io
external-ip kero.desk-spawner.io
external-ip kero.matrix-synapse.io
external-ip kero.chat.io
external-ip kero.vnc-<username>.io
external-ip kero.mail.io
external-ip kero.wiki.io
external-ip kero.ecommerce.io
```

Where external-ip is the external IP for the KERO cluster load balancer.

## Remote desktop service

### Create your desktop

To create your desktop, execute the command `deploy-vnc-server` with your username provided by the KERO cluster administrator. Enter your password when required to.

After finishing successfully, the command should give you an URL to access your remote desktop.

### Logging in and accessing a desktop

_Note_: Make sure your desktop is already deployed in the KERO cluster and ready to use.

To log in to your desktop, follow these steps:

1. Navigate to the URL of your remote desktop.

![](./img/vnc_login.png)

2. Enter your password.

![](./img/vnc_homepage.png)

### Destroy your desktop

When you are done using your desktop, just execute the command `destroy-vnc-server` with your username and password.

### How to use personal, group and shared storage

* Your **personal storage** is located under _/home/users/`<your-VNC-username>`/_
* Your **group storage** is located under _/home/users/`<your-group-name>`_ 
* The **shared storage** is located under _/mnt/shared/_

Feel free to save your personal data on your **personal storage**, group data on **group storage** and communal data on **shared storage**.

Every other directory is ephemeral storage. This means that data saved outside personal, group or shared storage will **not** be persisted after a reboot.

### Accessing the cluster from outside

To access to your desktop from an outside computer, follow these steps:

1. Do a POST against the desktop spawner service at _TODO/desks_ with the following body: 
```
{
    "user": "<your-vnc-username>",
    "password": "<your-vnc-password>"
}
```

For example:
```
curl  -X POST _TODO_ -d '{"user": "abarbetta", "password": "password"}' -H "Content-Type: application/json"
```

or use the script `vnc-connect` providing the desktop spawner URL and your credentials.

2. Navigate to the URL kero.vnc-`<your-VNC-username>`.io to log in and use your desktop.

3. When you are finished, do a DELETE against the desktop spawner (also with your credentials) to shutdown your desktop. You can also opt to use the script `vnc-disconnect` providing the desktop spawner URL and your credentials.

## Chat service

To use the chat service, navigate to the URL of the chat client.

![](./img/chat_welcome.png)

Then click on _Sign In_.

![](./img/chat_login.png)

Change the Matrix server to the KERO one.

![](./img/chat_login_2.png)

And lastly ingress with the username provided by your KERO cluster administrator.
