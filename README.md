# Cloud Computing Project: Deployment of a Docker Application in the Cloud

## Details of the Docker Application 

### Prerequisites 

Have Docker installed on your machine

### How to start the application

To start the application, open a commandline in the root folder and type *docker-compose up --build*

### Available commands 

* **apartments** Microservice: Add apartments with */add?name=...&size=...)"*
* **apartments** Microservice: Remove apartments with */remove?name=...)*
* **apartments** Microservice: See existing apartments with */apartments)*


* **Reserve** Microservice: Add a reservation with */add?name=...&start=yyyymmdd&duration=...&vip=1* 
    + Adding a reservation for a non-existing apartment is blocked
    + Adding a reservation that conflicts with another reservation is blocked
* **Reserve** Microservice: remove a reservation with */remove?id=...* 
* **Reserve** Microservice: See existing reservations with */reservations* 


* **Search** Microservice: Search for apartments with */search?date=...&duration=...* 
    + Apartments that are already booked are not shown in the search results

* The **Gateway** Microservice forwards the following commands to the correct microservices: 
    + /apartments
    + /apartments/apartments
    + /apartments/add
    + /apartments/remove
    + /search
    + /reserve
    + /reserve/reservations
    + /reserve/add
    + /reserve/remove

### Ports

| Microservice | Port |
| ------------ | ------ |
| Gateway | 5004 |
| apartments | 5001 |
| Search | 5002 |
| Reserve | 5003 | 

The correct URL for adding an apartment would be, for instance, *localhost:5001/add?name=apartment1&size=15*



