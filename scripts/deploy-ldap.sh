#! /bin/bash

set +x

export LDAP_IP="10.96.100.100"

if [[ -z "$1" ]]; then
    echo "INFO: No LDAP IP provided, defaulting to ${LDAP_IP}"
else
    export LDAP_IP="$1"    
fi

envsubst < /vagrant/manifests/ldap-server-deployment.yaml | kubectl apply -f -

LDAP_STATUS=$(kubectl get pods | grep ldap | awk '{print $3}') 
while [ $LDAP_STATUS != "Running" ]; do
    echo "Waiting for LDAP deployment (status: ${LDAP_STATUS})"
    sleep 6
    LDAP_STATUS=$(kubectl get pods | grep ldap | awk '{print $3}')
done

LDAP_PODNAME=$(kubectl get pods | grep ldap | awk '{print $1}')
kubectl cp /vagrant/manifests/posixAccount.xml default/$LDAP_PODNAME:var/www/phpldapadmin/templates/creation/posixAccount.xml

echo "Connect to LDAP admin panel on ${LDAP_IP}"
