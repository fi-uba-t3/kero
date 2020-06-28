import os
import logging
import hashlib
from flask import Flask, render_template, request, redirect, make_response
from ldapmanager import LDAPManager

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)
app.config["LDAP_PASSWORD_SHA224"] = hashlib.sha224(
    bytes(os.getenv("LDAP_PASSWORD", "admin"), "utf-8")).hexdigest()

mgr = LDAPManager(
    host=os.getenv("LDAP_IP", "localhost"),
    dn=os.getenv("LDAP_DN", "fiuba.com"))

#TODO: check hierarchy
#TODO: login w/cookie
impressions = 0

@app.before_first_request
def check_ldap_status():
    if not mgr.logged_in:
        mgr.login(os.getenv("LDAP_PASSWORD", "admin"))
    if not mgr.check_hierarchy():
        mgr.prepare_hierarchy()

@app.route("/")
def index():
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    num_users = len(mgr.find_users())
    num_groups = len(mgr.find_groups())
    return render_template("index.html", current_page="index",
        num_users=num_users, num_groups=num_groups)

@app.route("/login", methods=["GET"])
def login():
    #request.cookies.get('YourSessionCookie')
    return render_template("login.html")

@app.route("/login", methods=["POST"])
def do_login():
    #request.cookies.get('YourSessionCookie')
    if hashlib.sha224(bytes(
        request.form["password"],"utf-8")).hexdigest() == app.config["LDAP_PASSWORD_SHA224"]:
        if not mgr.logged_in:
            mgr.login(request.form["password"])
        response = redirect("/")
        response.set_cookie('session', app.config["LDAP_PASSWORD_SHA224"])
        return response

    return render_template("login.html", incorrect_password=True)

@app.route("/logout")
def do_logout():
    response = make_response(render_template("login.html", logged_out=True))
    response.set_cookie('session', '', expires=0)
    return response

@app.route("/users")
def list_users():
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    users = mgr.find_users()
    groups = mgr.find_groups()
    group_mapping = {group["group_number"][0]:group["group_name"][0] for group in groups}
    secondary_members_mapping = {u["username"][0]:[] for u in users}
    for group in groups:
        for user in group.get("secondary_members", ""):
            secondary_members_mapping[user].append(group["group_name"][0])

    for user in users:
        user["groups"] = [group_mapping[group_number] for group_number in user["group_number"]]

    return render_template("users.html", current_page="users",
        users=users, group_mapping=group_mapping, secondary_members_mapping=secondary_members_mapping)

@app.route("/groups")
def list_groups():
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    groups = mgr.find_groups()
    return render_template("groups.html", current_page="groups", groups=groups)

@app.route("/groups/user/<username>", methods=["GET"])
def list_groups_for_user(username):
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    groups = mgr.get_groups_for_user(username)
    original_groups = [group['group_name'][0]
                       for group in groups if group['belongs']]
    return render_template("groups_user.html",
        current_page="groups", groups=groups, username=username, original_groups=str(original_groups))

@app.route("/groups/user/<username>", methods=["POST"])
def change_groups_for_user(username):
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")


    received_groups = set(request.form.to_dict().keys())

    groups = mgr.get_groups_for_user(username)
    original_groups = {group['group_name'][0]
                       for group in groups if group['belongs']}

    for group in original_groups.union(received_groups):
        if group not in original_groups:
            mgr.add_user_to_group(username, group)
        if group not in received_groups:
           mgr.remove_user_from_group(username, group)

    return redirect("/users")

@app.route("/new_user", methods=["GET"])
def new_user_form():
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    global impressions
    impressions+=1
    groups = mgr.find_groups()
    return render_template("new_user.html", current_page="new_user", groups=groups, impressions=impressions)

@app.route("/new_user", methods=["POST"])
def new_user():
    global impressions
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    status = mgr.add_user(request.form["username"], request.form["inputPassword"], request.form["firstName"],
                    request.form["lastName"], request.form["groupNumber"])
    success = status == mgr.OK
    error = "" if success else status
    groups = mgr.find_groups()
    return render_template("new_user.html", current_page="new_user", impressions=impressions,
                           success=success, error=error, groups=groups)

@app.route("/new_group", methods=["GET"])
def new_group_form():
    global impressions
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    impressions+=1
    return render_template("new_group.html", current_page="new_group", impressions=impressions)

@app.route("/new_group", methods=["POST"])
def new_group():
    global impressions
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    impressions+=1
    status = mgr.add_group(request.form["groupName"])
    success = status == mgr.OK
    error = "" if success else status
    return render_template("new_group.html", current_page="new_group", impressions=impressions,
                           success=success, error=error)

@app.route("/delete_user/<username>", methods=["GET"])
def delete_user_form(username):
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    return render_template(
        "delete_user.html", current_page="delete_user",
        username=username)


@app.route("/delete_user/<username>", methods=["POST"])
def delete_user(username):
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    status = mgr.remove_user(username)
    success = status == mgr.OK
    error = "" if success else status
    return render_template(
        "delete_user.html", current_page="delete_user",
        username=username, error=error, success=success)


@app.route("/monitoreo")
def monitor():
    if request.cookies.get("session", "") != app.config["LDAP_PASSWORD_SHA224"]:
        return redirect("/login")

    return render_template("monitoreo.html", current_page="monitor")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)