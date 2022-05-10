# Cloud Computing Project: Deployment of a Docker Application in the Cloud 

## Details of the Docker Application 

### How to access

Open 54.80.67.161:5004. You will be on the homepage. 

### Available commands 

* **apartments** Microservice: Home with *.../apartments*
* **apartments** Microservice: Add apartments with *.../apartments/add?name=...&size=...)"*
* **apartments** Microservice: Remove apartments with *.../apartments/remove?name=...)*
* **apartments** Microservice: See existing apartments with *.../apartments/apartments)*

* **Reserve** Microservice: Home with *.../reserve*
* **Reserve** Microservice: Add a reservation with *.../reserve/add?name=...&start=yyyymmdd&duration=...&vip=1* 
    + Adding a reservation for a non-existing apartment is blocked
    + Adding a reservation that conflicts with another reservation is blocked
* **Reserve** Microservice: remove a reservation with *.../reserve/remove?id=...* 
* **Reserve** Microservice: See existing reservations with *.../reserve/reservations* 

* **Search** Microservice: Home with *.../search*
* **Search** Microservice: Search for apartments with *.../search/search?date=...&duration=...* 
    + Apartments that are already booked are not shown in the search results

