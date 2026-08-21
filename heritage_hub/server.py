# heritage_hub/server.py
from flask import Flask, render_template, jsonify
from heritage_hub.core.db import get_db

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({"message": "Heritage Hub — API", "version": "0.1.0"})

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
