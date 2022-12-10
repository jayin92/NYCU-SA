import os
import sys
from flask import Flask, json

app = Flask(__name__)

@app.route("/")
def index():
    with open("./data/free_space.txt", "r") as f:
        free_space = int(f.read())
    with open("./data/total_space.txt", "r") as f:
        total_space = int(f.read())
    with open("./data/boot_time.txt", "r") as f:
        boot_time = int(f.read())
    with open("./data/current_time.txt", "r") as f:
        current_time = int(f.read())
    data = {
        "disk": free_space / total_space,
        "uptime": current_time - boot_time,
        "time": current_time,
    }
    response = app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype='application/json'
    )
    return response

if __name__ == "__main__":
    domain=sys.argv[1]
    app.run(host="0.0.0.0", port=80)