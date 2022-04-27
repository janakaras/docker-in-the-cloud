from flask import request
from flask import Flask, redirect
from flask import Response
import logging
import consul
import time
import requests

app = Flask(__name__)

def find_service(name):
    connection = consul.Consul(host="consul", port=8500)
    _, services = connection.health.service(name, passing=True) 
    for service_info in services:
        address = service_info["Service"]["Address"]
        port = service_info["Service"]["Port"]
        return address, port
    return None, None

# gateway hello world
@app.route("/")
def hello():
    return "Hello World from the best team of the world! xoxo"

# Apartments
@app.route("/apartments/apartments")
@app.route("/apartments/add")
@app.route("/apartments")
@app.route("/apartments/remove")
def apartments(): 
    address, port = find_service("apartments")
    url = request.url.replace(request.host_url + "apartments", f"http://{address}:{port}")
    logging.info(f"Requesting content from {url} ...")
    response = requests.get(url)
    return Response(response.content, response.status_code, mimetype="application/json")

# Search
@app.route("/search")
def search(): 
    address, port = find_service("search")
    url = request.url.replace(request.host_url, f"http://{address}:{port}/")
    logging.info(f"Requesting content from {url} ...")
    response = requests.get(url)
    return Response(response.content, response.status_code, mimetype="application/json")

# Reserve
@app.route("/reserve/reservations")
@app.route("/reserve/add")
@app.route("/reserve")
@app.route("/reserve/remove")
def reservations(): 
    address, port = find_service("reserve")
    url = request.url.replace(request.host_url + "reserve", f"http://{address}:{port}")
    logging.info(f"Requesting content from {url} ...")
    response = requests.get(url)
    return Response(response.content, response.status_code, mimetype="application/json")

# consul
def register(): 
    time.sleep(10)
    while True:
        try:
            connection = consul.Consul(host='consul', port=8500)
            connection.agent.service.register("gateway", address="127.0.0.1", port=5004)
            break
        except (ConnectionError, consul.ConsulException): 
            logging.warning('Consul is down, reconnecting...') 
            time.sleep(5) 

if __name__ == "__main__":
    logging.info("Starting the web server.")

    register()

    app.run(host="0.0.0.0", threaded=True)

