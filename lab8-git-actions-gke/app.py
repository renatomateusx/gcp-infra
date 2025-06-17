# app.py
from flask import Flask
import random

app = Flask(__name__)

@app.route("/")
def home():
    if random.randint(0, 1) == 0:
        return "OK", 200
    else:
        return "ERROR", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
