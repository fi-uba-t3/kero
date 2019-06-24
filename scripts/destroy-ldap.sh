#! /bin/bash

set +x

export LDAP_IP="10.96.100.100"

if [[ -z "$1" ]]; then
    echo "INFO: No LDAP IP provided, defaulting to ${LDAP_IP}"
else
    export LDAP_IP="$1"    
fi

read -p "WARNING! If you proceed you will totally erase LDAP with all its info. Are you sure? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

envsubst < /vagrant/manifests/ldap-server-deployment.yaml | kubectl delete -f -

echo "LDAP deleted."
