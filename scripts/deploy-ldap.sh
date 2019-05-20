#! /bin/bash
kubectl apply -f /vagrant/manifests/ldap-server.yaml
sleep 8
LDAP_POD=$(kubectl get pods | grep ldap | awk '{print $1}')
kubectl cp /vagrant/manifests/posixAccount.xml default/$LDAP_POD:var/www/phpldapadmin/templates/creation/posixAccount.xml
