# heritage_hub/server.py
from flask import Flask, jsonify
from heritage_hub.core.db import get_db
from heritage_hub.modules.m1_planches.views import register_routes

app = Flask(__name__)

# Enregistrer les routes du module M1
register_routes(app)

@app.route("/")
def index():
    return jsonify({"message": "Heritage Hub — API", "version": "0.1.0"})

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
