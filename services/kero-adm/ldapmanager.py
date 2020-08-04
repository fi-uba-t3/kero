import ldap
import ldap.modlist
import logging
def s2b(string):
    return bytes(string, "utf-8")

class LDAPManager:
    OK="OK" # To check result of ops.
    def __init__(self, host="localhost", port=389, dn="fiuba.com"):
        logging.info("Connecting to LDAP server at %s:%d", host, port)
        self.connection = ldap.initialize(f"ldap://{host}:{port}")
        self.connection.set_option(ldap.OPT_REFERRALS, 0)
        logging.info("Setting LDAP DN to %s", dn)
        self.dn = dn
        self.qualified_dn = f"dc={',dc='.join(self.dn.split('.'))}"
        self.logged_in = False
        #if kickstart_hierarchy and not self.check_hierarchy():
        #    self.prepare_hierarchy()

    def login(self, password):
        if self.logged_in:
            logging.info("Already logged in, ignoring attempt..")
            return
        user = f"cn=admin,{self.qualified_dn}"
        try:
            self.connection.simple_bind_s(user, password)
            self.logged_in = True
        except ldap.LDAPError as ldap_error:
            logging.error(self.parse_error(ldap_error))

    def logout(self):
        print("Logging out!")
        logging.info("Logged out!")
        self.logged_in = False
        self.connection.unbind()

    def __del__(self):
        if self.logged_in:
            self.logout()

    def ugly_to_nice_query(self, query, ugly_names, nice_names):
        """Replaces attribute names and converts bytes to strings in a
        list of dictionaries, which is what LDAP returns."""
        #print(query)
        result=[ {nice_attr:[string.decode("utf-8") for string in cn_dict[1].get(ugly_attr, [])]
                  for ugly_attr, nice_attr in zip(ugly_names, nice_names)}
                for cn_dict in query]
        #print("Parsed:", result)
        return result

    def find_users(self):
        query = self.connection.search_s(
            f"ou=People,{self.qualified_dn}",
            ldap.SCOPE_SUBTREE,
            '(objectClass=PosixAccount)',
            ['memberOf', 'uidNumber', "uid", "gidNumber", "givenName", "sn"])
        users = self.ugly_to_nice_query(
            query,
            ["uidNumber", "uid","givenName","sn","gidNumber"],
            ["userid", "username", "first_name", "last_name", "group_number"])
        return users

    def find_user(self, username):
        query = self.connection.search_s(
            self.user_dn(username),
            ldap.SCOPE_SUBTREE,
            '(objectClass=PosixAccount)',
            ['memberOf', 'uidNumber', "uid", "gidNumber", "givenName", "sn"])
        user = self.ugly_to_nice_query(
            query,
            ["uidNumber", "uid","givenName","sn","gidNumber"],
            ["userid", "username", "first_name", "last_name", "group_number"])
        return user

    def find_groups(self):
        query = self.connection.search_s(
            f"{self.qualified_dn}",
            ldap.SCOPE_SUBTREE,
            '(objectClass=PosixGroup)',
            ['memberOf', 'cn', 'gidNumber', "memberUid"]
        )
        groups = self.ugly_to_nice_query(
            query,
            ["cn","gidNumber","memberUid"],
            ["group_name", "group_number","secondary_members"]
        )
        return groups

    def prepare_hierarchy(self):
        #create ou=People
        people_dn = f"ou=People,{self.qualified_dn}"
        modlist = {
            "objectClass": [b"organizationalUnit", b"top"],
            "ou":b"People"
        }
        return self.connection.add_s(people_dn, ldap.modlist.addModlist(modlist))

    def check_hierarchy(self):
        #check ou=People
        try:
            search_results = self.connection.search_s(
                f"ou=People,{self.qualified_dn}",
                ldap.SCOPE_SUBTREE,
                '(objectClass=organizationalUnit)',
                ['ou'])
            return len(search_results) > 0
        except ldap.NO_SUCH_OBJECT:
            return False

    def user_dn(self, username):
        return f"uid={username},ou=People,{self.qualified_dn}"

    def group_dn(self, group_name):
        return f"cn={group_name},{self.qualified_dn}"

    def add_user(self, username, password, first_name, last_name, group_number):
        "Add a user to the People organizational unit"
        existing_users = self.find_users()
        user_dn = self.user_dn(username)
        max_user_id = 5000
        if len(existing_users):
            max_user_id = max([int(user["userid"][0]) for user in existing_users])

        modlist = {
            "objectClass": [b"inetOrgPerson", b"posixAccount", b"top"],
            "uid": [s2b(username)],
            "sn": [s2b(last_name)],
            "givenName": [s2b(first_name)],
            "cn": [s2b(f"{first_name} {last_name}")],
            "displayName": [s2b(f"{first_name} {last_name}")],
            "uidNumber": [s2b(str(max_user_id+1))],
            "userPassword": [s2b(password)],
            "gidNumber": [s2b(str(group_number))],
            "loginShell": [s2b("/bin/bash")],
            "homeDirectory": [s2b(f"/home/{username}")],
            "memberOf": []
        }
        try:
            self.connection.add_s(user_dn, ldap.modlist.addModlist(modlist))
        except ldap.LDAPError as ldap_error:
            return self.parse_error(ldap_error)

        return self.OK

    def parse_error(self, ldap_error):
        if not isinstance(ldap_error.args[0], dict):
                return f"Error: {str(err)}"

        error_str = "\n".join(filter(None,[ldap_error.args[0].get(key, "")
                                      for key in ["desc", "info", "matched"]]))
        # Handle known cases.
        if error_str == "Already exists":
            return "El nombre ya existe."
        elif ("memberUid" in error_str) and ("already exists" in error_str):
            return "El usuario ya está en el grupo."

        return error_str

    def add_group(self, name):
        """Add a group to the root, return False if group name already exists"""
        existing_groups = self.find_groups()
        if existing_groups:
            max_group_id = max([int(group['group_number'][0]) for group in existing_groups])
        else:
            max_group_id = 500

        if s2b(name) in [group["group_name"][0] for group in existing_groups]:
            return False # Already exists

        group_dn = self.group_dn(name)
        modlist = {
            "objectClass": [b"posixGroup", b"top"],
            "cn": [s2b(name)],
            "gidNumber": [s2b(str(max_group_id+1))],
            "memberUid": []
        }

        try:
             self.connection.add_s(group_dn, ldap.modlist.addModlist(modlist))
             return self.OK
        except ldap.LDAPError as ldap_error:
            return self.parse_error(ldap_error)

    def get_groups_for_user(self, username):
        user = self.find_user(username)[0]
        groups = self.find_groups()
        for group in groups:
            group["belongs"] = True
            group["primary"] = True

            if user["username"][0] in group.get("secondary_members", []):
                group["primary"] = False
            elif group["group_number"][0] != user["group_number"][0]:
                group["primary"] = False
                group["belongs"] = False
        return groups


    def get_users_in_group(self, group_name):
        #TODO:
        group_dn = self.group_dn(group_name)
        return self.connection.search_s(f"ou=People,{self.qualified_dn}",
            ldap.SCOPE_SUBTREE, "", None)

    def _modify_membership_op(self, username, group_name, op):
        """Modify membership of user in group.
        `op` must be ldap.MOD_ADD or ldap.MOD_DELETE"""
        try:
            self.connection.modify_s(
                self.group_dn(group_name),
                [
                    (op, 'memberUid',[s2b(username)])
                ]
            )
            return self.OK
        except ldap.LDAPError as ldap_error:
            return self.parse_error(ldap_error)

    def add_user_to_group(self, username, group_name):
        return self._modify_membership_op(username, group_name, ldap.MOD_ADD)

    def remove_user_from_group(self, username, group_name):
        return self._modify_membership_op(username, group_name, ldap.MOD_DELETE)

    def remove_user(self, username):
        user_dn = f"uid={username},ou=People,{self.qualified_dn}"
        groups = self.get_groups_for_user(username)
        for group in groups:
            if group["belongs"]:
                self.remove_user_from_group(username, group["group_name"][0])
        try:
            self.connection.delete_s(user_dn)
            return self.OK
        except ldap.LDAPError as ldap_error:
            return self.parse_error(ldap_error)

    def remove_group(self, group_name):
        group_dn = self.group_dn(group_name)
        try:
            self.connection.delete_s(group_dn)
            return self.OK
        except ldap.LDAPError as ldap_error:
            return self.parse_error(ldap_error)


#TODO: check staleness of ldap connection
#TODO: query para obtener y remover las relaciones usuario-grupo => en un solo paso?
#TODO: query para agregar usuario a grupo