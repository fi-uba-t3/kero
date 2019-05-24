#! /bin/bash
kubectl apply -f /vagrant/manifests/ldap-server.yaml
LDAP_STATUS=$(kubectl get pods | grep ldap | awk '{print $3}') 
while [ $LDAP_STATUS != "Running" ]; do
    echo "Waiting for LDAP deployment (status: ${LDAP_STATUS})"
    sleep 5
    LDAP_STATUS=$(kubectl get pods | grep ldap | awk '{print $3}')
done
LDAP_PODNAME=$(kubectl get pods | grep ldap | awk '{print $1}')
kubectl cp /vagrant/manifests/posixAccount.xml default/$LDAP_PODNAME:var/www/phpldapadmin/templates/creation/posixAccount.xml
LDAP_IP=$(kubectl describe pod $LDAP_PODNAME | grep "Node:" | cut -d "/" -f 2)
echo "Connect to LDAP admin panel on ${LDAP_IP}:30666"
