from flask import Flask, render_template, request
import os, subprocess
app = Flask(__name__)

create_desk_cmd = "echo %s | bash /vagrant/vnc/deploy-vnc-server %s"
desk_url_cmd = "kubectl get svc --no-headers | grep %s | awk '{print $3}'"
delete_desk_cmd = "echo %s | bash /vagrant/vnc/delete-vnc-server %s"

@app.route("/")
def main():
    return "Welcome! POST to /desks with your credentials to instantiate a desk"

@app.route("/desks", methods=['POST'])
def new_desk():
    body = request.json
    print(body)
    user = body['user']
    password = body['password']
    
    print("Creating a new desk for user '%s' with pass '%s'" % (user, password))
    os.system(create_desk_cmd % (password, user))

    output = subprocess.check_output(desk_url_cmd, shell=True)
    return "Your desk is up on %s, please delete it when you are done." % output

@app.route("/desks", methods=['DELETE'])
def delete_desk():
    body = request.json
    print(body)
    user = body['user']
    password = body['password']

    print("Deleting desk for user '%s' with pass '%s'" % (user, paqssword))
    os.system(delete_desk_cmd % (password, user))

    return "Done"

def run_cmd(command):
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    return output, error

if __name__ == "__main__":
    app.run(host= '0.0.0.0')