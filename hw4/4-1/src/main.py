import os
import sys
import jwt
import bcrypt
import base64
from flask import Flask, request, jsonify

app = Flask(__name__)

login_info = dict()

@app.route("/auth/", methods=["GET"])
def auth():
    # Deal with http basic auth and jwt
    if request.headers.get("Authorization") is None:
        return jsonify({ "error": "Authorization header not found" }), 403
    
    if str(request.headers.get("Authorization")).find("Bearer") == -1:
        # http basic auth
        auth = request.headers.get("Authorization").split(" ")
        if len(auth) != 2:
            return jsonify({ "error": "Authorization header format error" }), 403
        username, password = base64.b64decode(auth[1].encode()).decode().split(":")
        username = str(username)
        password = str(password)
        if username not in login_info or str(request.headers.get("X-Original-URI")).find(username) == -1:
            return jsonify({ "error": "username not found" }), 403
        if bcrypt.checkpw(password.encode(), login_info[username].encode()):
            return "Success", 200
        return jsonify({ "error": "password incorrect" }), 403
    else:
        # jwt
        token = request.headers.get("Authorization").split(" ")[1]
        try:
            payload = jwt.decode(token, app.config['JWT_SECRET_KEY'], algorithms="HS256")
        except:
            return jsonify({ "error": "token invalid" }), 403
        if payload["user"] not in login_info or str(request.headers.get("X-Original-URI")).find(payload["user"]) == -1:
            return jsonify({ "error": "user not found" }), 403
        return "Success", 200


@app.route("/login/", methods=["POST"])
def login():
    # get username and password from json or x-www-form-urlencoded

    if request.headers.get("Content-Type") == "application/json":
        data = request.get_json()
        username = data["username"]
        password = data["password"]
    else:
        username = request.form["username"]
        password = request.form["password"]

    username = str(username)
    password = str(password)
    # check username and password using bcrypt
    if username not in login_info:
        return jsonify({ "error": "username not found" }), 403
    print(login_info[username])
    if bcrypt.checkpw(password.encode(), login_info[username].encode()):
        payload = dict()
        payload["user"] = username
        token = jwt.encode(payload, app.config['JWT_SECRET_KEY'], algorithm="HS256")
        return token, 200

    return jsonify({ "error": "password incorrect" }), 403

if __name__ == "__main__":
    app.config['JWT_SECRET_KEY'] = sys.argv[1]
    with open("/home/judge/hw4/4-1/data/.htpasswd", "r") as f:
        for line in f:
            username, password = line.strip().split(":")
            login_info[str(username)] = str(password)
    
    app.run(host="0.0.0.0", port=8080)