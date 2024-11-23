from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def handle_webhook():
    # Optional: Add security checks or parse the payload
    subprocess.call(["/path/to/sonar-scan.sh"])
    return "Webhook received and script executed", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

