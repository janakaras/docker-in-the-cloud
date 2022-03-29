import sqlite3
import uuid
from flask import request
from flask import Flask
from flask import Response
import logging
import pika
import json
import consul
import time
import os
import time

app = Flask(__name__)


@app.route("/add")
def add():
    id = uuid.uuid4()
    name = request.args.get("name")
    size = request.args.get("size")

    if name == None:
        return Response('{"result": false, "error": 1, "description": "Cannot proceed because you did not provide a name for the apartment."}', status=400, mimetype="application/json")

    if size == None:
        return Response('{"result": false, "error": 1, "description": "Cannot proceed because you did not provide a size for the apartment."}', status=400, mimetype="application/json")

    # Connect and setup the database
    connection = sqlite3.connect("/home/data/apartments.db", isolation_level=None)
    cursor = connection.cursor()
    cursor.execute("CREATE TABLE IF NOT EXISTS apartments (id text, name text, squaremeters int)")

    # Check if apartment already exists
    cursor.execute("SELECT COUNT(id) FROM apartments WHERE name = ? AND squaremeters = ?", (name, size))
    already_exists = cursor.fetchone()[0]
    if already_exists > 0:
        return Response('{"result": false, "error": 2, "description": "Cannot proceed because this apartment already exists"}', status=400, mimetype="application/json")

    # Add apartment
    cursor.execute("INSERT INTO apartments VALUES (?, ?, ?)", (str(id), name, size))
    cursor.close()
    connection.close()

    # Notify everybody that the apartment was added
    connection = pika.BlockingConnection(pika.ConnectionParameters("rabbitmq"))
    channel = connection.channel()
    channel.exchange_declare(exchange="apartments", exchange_type="direct")
    channel.basic_publish(exchange="apartments", routing_key="added", body=json.dumps({"id": str(id), "name": name, "size": size}))
    connection.close()

    return Response('{"result": true, description="apartment was added successfully."}', status=201, mimetype="application/json")

@app.route("/remove")
def remove():
    name = request.args.get("name")

    if name == None:
        return Response('{"result": false, "error": 1, "description": "Cannot proceed because you did not provide the name of the apartment you want to remove."}', status=400, mimetype="application/json")

    # connect to database
    connection = sqlite3.connect("/home/data/apartments.db", isolation_level=None)
    cursor = connection.cursor()
    cursor.execute("CREATE TABLE IF NOT EXISTS apartments (id text, name text, squaremeters int)")

    # get id if the apartment exists
    cursor.execute("SELECT id FROM apartments WHERE name = ?", (name,))
    existing = cursor.fetchone()
    if existing is None:
        return Response('{"result": false, "error": 2, "description": "Cannot proceed because this apartment does not exist"}', status=400, mimetype="application/json")
    else:
        id =  existing[0]
        cursor.execute("DELETE FROM apartments WHERE id = ?", (id,))
    
    # remove apartment
    cursor.close()
    connection.close()

    # Notify everybody that the apartment was removed
    connection = pika.BlockingConnection(pika.ConnectionParameters("rabbitmq"))
    channel = connection.channel()
    channel.exchange_declare(exchange="apartments", exchange_type="direct")
    channel.basic_publish(exchange="apartments", routing_key="removed", body=json.dumps({"id": str(id), "name": name}))
    connection.close()

    return Response('{"result": true, "description": "apartment was removed successfully."}', status=400, mimetype="application/json")

    
@app.route("/")
def hello():
    return "Hello World from apartments!"

@app.route("/apartments")
def apartments():
    if os.path.exists("/home/data/apartments.db"):

        # connect to db 
        connection = sqlite3.connect("/home/data/apartments.db", isolation_level=None)
        cursor = connection.cursor()

        # create table if it does not exist yet
        cursor.execute("CREATE TABLE IF NOT EXISTS apartments (id text, name text, start text, duration int, vip int)")
        
        # get data 
        cursor.execute("SELECT * FROM apartments")
        columns = [col[0] for col in cursor.description]
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
        return json.dumps({"apartments": rows})

    return json.dumps({"apartments": []})

def register(): 
    time.sleep(10)
    while True:
        try:
            connection = consul.Consul(host='consul', port=8500)
            connection.agent.service.register("apartments", address="apartments", port=5000)
            break
        except (ConnectionError, consul.ConsulException): 
            logging.warning('Consul is down, reconnecting...') 
            time.sleep(5) 

def deregister(): 
    connection = consul.Consul(host='consul', port=8500)
    connection.agent.service.deregister("apartments", address="apartments", port=5000)

if __name__ == "__main__":
    logging.info("Starting the web server.")

    register()

    app.run(host="0.0.0.0", threaded=True)