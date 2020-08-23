<?php
/**
 * Dokuwiki's Main Configuration File - Local Settings
 */
$conf['title'] = 'KeroWiki';
$conf['basedir'] = '/wiki/';
$conf['license'] = 'cc-by-sa';
$conf['useacl'] = 1;
$conf['authtype'] = 'authldap';
$conf['superuser'] = '@admin';
$conf['disableactions'] = 'register';
$conf['plugin']['authldap']['server'] = 'ldap://10.96.100.100:389';
$conf['plugin']['authldap']['binddn'] = 'cn=admin,dc=fiuba,dc=com';
$conf['plugin']['authldap']['bindpw'] = 'admin';
$conf['plugin']['authldap']['version'] = 3;
$conf['plugin']['authldap']['usertree'] = 'ou=People,dc=fiuba,dc=com';
$conf['plugin']['authldap']['userfilter'] = '(&(uid=%{user})(objectClass=posixAccount))';
$conf['plugin']['authldap']['attributes'] = array('cn', 'uid', 'mail');
