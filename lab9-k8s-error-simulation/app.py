from flask import Flask, jsonify
import random
import time
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({"message": "Hello from Error Simulation App!", "status": "healthy"})

@app.route('/error')
def simulate_error():
    # Simula diferentes tipos de erros
    error_types = [
        {"error": "Database connection failed", "code": 500},
        {"error": "Timeout error", "code": 408},
        {"error": "Memory overflow", "code": 500},
        {"error": "Network timeout", "code": 504}
    ]
    
    error = random.choice(error_types)
    return jsonify(error), error["code"]

@app.route('/slow')
def slow_response():
    # Simula resposta lenta
    time.sleep(random.uniform(1, 5))
    return jsonify({"message": "Slow response completed", "duration": "1-5 seconds"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "timestamp": time.time()})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False) 