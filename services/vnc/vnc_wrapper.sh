#!/bin/bash
### every exit != 0 fails the script
set -e

echo "Starting nslcd daemon"
sudo nslcd -d > /var/log/nslcd.log 2>&1 &
echo "nslcd running on $!"

## Wait for nslcd to start
sleep 5

## Set up entry in /etc/passwd to avoid appearing as default user
VNC_USER_ID=$(id -u ${VNC_USER})
VNC_USER_GROUPID=$(id -g ${VNC_USER})
echo "${VNC_USER}:x:${VNC_USER_ID}:${VNC_USER_GROUPID}:${VNC_USER}:/home/users/${VNC_USER}:/bin/bash" >> /etc/passwd

## Set up permissions for shared, group and home
su -m ${VNC_USER} -c "date"
chown ${VNC_USER_ID} /home/users/${VNC_USER}
chgrp 500 /mnt/shared
chgrp 500 /home/users/group
chgrp 500 /home/users/${VNC_USER_GROUPID}/

echo "Running vnc_startup"
su -m ${VNC_USER} /dockerstartup/vnc_startup.sh "$@"
