#!/bin/bash
### every exit != 0 fails the script
set -e

echo "Starting nslcd daemon"
sudo nslcd -d > /var/log/nslcd.log 2>&1 &
echo "nslcd running on $!"

echo "Running vnc_startup"
/dockerstartup/vnc_startup.sh "$@"
