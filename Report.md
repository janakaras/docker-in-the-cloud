# Cloud Computing Project: 
## Deployment of a Docker-based application in the cloud


## Contents

1. [ Problem description ](#desc)  
    1.1 [ Starting Point ](#start)  
    1.2 [ Goal ](#goal)

2. [ Basic Structure and Tools ](#basic_tools)  
    2.1 [ Basic Structure ](#basic_structure)  
    2.2 [ Docker ](#docker)  
    2.3 [ GitHub Actions ](#github_actions)  
    2.4 [ Terraform ](#terraform)  
    2.5 [ AWS ](#aws)  

3. [ Final Implementation ](#impl)  
    3.1 [ Solution 1 - zip ](#zip)  
    3.2 [ Solution 2 - Docker Hub ](#docker_hub)  

4. [ Challenges in the Progress ](#challenges)  

5. [ Discussion ](#discussion)  

6. [ Conclusion ](#conclusion)  

## 1. Problem description <a name="desc"></a>

### 1.1 Starting Point <a name="start"></a>

The starting point of the project was a Docker-based web application for managing apartments that the students of the Software Engineering Master developed in 
the semester before (WS2021). The application can be cloned from the unibz instance of GitLab:  
https://gitlab.inf.unibz.it/Jana.Karas/cloud-computing-project  

The core part of the application consists of three docker containers that contain flask apps fulfilling the following services:  
* Apartments: Add new apartments or remove apartments that are no longer offered.
* Search: Search for free apartments in a given timeframe.
* Reserve: Make or cancel reservations for free apartments.

The containers communicate via a RabbitMQ Message Queue, which resides in another container. Furthermore, the application has a Portainer container 
for managing the containers and a Consul container for Service Registry.

#### Details of the Docker Application <a name="docker_details"></a>

##### How to access

Open 54.80.67.161:5004. You will be on the homepage. 

##### Available commands 

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


### 1.2 Goal <a name="goal"></a>

The goal was to deploy our web application in the cloud. All included steps such as setting up the infrastructure, upload the application to the cloud environment, starting the app in the cloud, etc. were supposed to be automated in a CI/CD-Pipeline.
 
## 2. Basic Structure and Tools <a name="basic_tools"></a>

### 2.1 Basic Structure <a name="basic_structure"></a>

We moved the whole existing Docker-based web application to GitHub, so we could work together on the project as a team. Also, GitHub provided the general framework to set up automated workflows to deploy our app in the cloud with GitHub Actions. In such a workflow, we used Terraform to set up the cloud infrastructure and created a virtual machine on the cloud platform AWS where we could deploy our web app by using Docker to upload and run the application.

<br />
<br />
<p align="center" ><img src="/images/basic_idea.png" width="500"></p>
<br />
<br />

### 2.2 Docker <a name="docker"></a>

The application is composed of Docker containers. [Docker](https://www.docker.com/) is a software framework for building, running, and managing containers on servers and the cloud. A Docker container image is a package of software that includes everything needed to run an application. Our application is made of several containers which can be run by the tool [Docker Compose](https://docs.docker.com/compose/).  
Both Docker and Docker Compose needed to be installed on the virtual machine in the cloud.  
To deliver the images of our application to the cloud, we used the option to save them on [Docker Hub](https://hub.docker.com/). Docker Hub is a hosted repository service provided by Docker for finding and sharing container images with your team.

### 2.3 GitHub Actions <a name="github_actions"></a>

We used [GitHub](https://github.com/), an online software development platform based on the open-source version control software Git, to collaborate on the project together. GitHub includes the continuous integration and continuous delivery (CI/CD) platform [GitHub Actions](https://github.com/features/actions). GitHub Actions enables you to design workflows which will be triggered by for example changes in the application's code that are pushed to GitHub. With GitHub Actions, we were able to automatically deploy our application in the cloud without any manual steps necessary in the course of the workflow.  
There are a lot of public available GitHub Actions, that we could for example use to set up our infrastructure to deploy the application in the cloud.

### 2.4 Terraform <a name="terraform"></a>

To set up the cloud infrastructure, we used the open source infrastructure as a code (IaaC) software tool HashiCorp's [Terraform](https://www.terraform.io/) that lets you  build, change, and version public cloud infrastructure. In Terraform, we could configure the virtual machine in the cloud suited to our needs.  
We used the SaaS platform [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) to save secret configuration variables for security reasons. Also, Terraform Cloud lets you save the state of your infrastructure remotely so the system knows whether to create or update the configured cloud infrastructure.

### 2.5 AWS <a name="aws"></a>

To host our application, we used the Free Tier offerings of [AWS](https://aws.amazon.com/) (Amazon Web Services). AWS is a cloud computing platform provided by Amazon that includes a mixture of infrastructure as a service (IaaS), platform as a service (PaaS) and packaged software as a service (SaaS) offerings. Among the big offering of AWS, the cloud platform provides the usage of virtual machines called Amazon Elastic Compute Cloud ([Amazon EC2](https://aws.amazon.com/ec2/)). We used these EC2 instances to deploy our application on AWS. AWS provides a great amount of EC2 instances with different configurations of CPU, memory, storage and networking resources. With the AWS Free Tier, we had some options to try our setup on Linux t2.micro instances for free.  


### 3. Final Implementation <a name="impl"></a>

#### 3.1 Solution 1 - zip <a name="zip"></a>

Both of our final solutions follow the basic described structure:  
Following a trigger a GitHub Actions workflow starts. In the workflow with the help of Terraform an EC2 instance is created or if already existing updated. This will be decided by the remote state file in Terraform Cloud. In Terraform the configuration of the EC2 instance is defined. The correct security groups are defined and assigned, an Elastic IP which was created in the AWS account is assigned and in the User Data of the configuartion implementation Docker and Docke-Compose are installed in the EC2 instance.
After the creation of the EC2 instance we worked out two solutions to upload the application to the cloud. In the first solution the first step was to access the instance from the wokflow. This was done via SSH and the predefined Elastic IP. To upload the application we used in our first solution the from GitHub provided .zip link to bring the whole application in the cloud. There we unziped the folder and run the on the instance installed docker-compose up to start the application.

<br />
<br />
<p align="center" ><img src="/images/workflow_zip.png" width="750"></p>
<br />
<br />

#### 3.2 Solution 2 - Docker Hub <a name="docker_hub"></a>

In the second solution we followed a different approach to upload the application to the cloud. In a first workflow the images of the Docker containers got published to Docker Hub. After that the EC2 instance got created like in the first described solution. The third step was to access the images from the running EC2 machine. Here we first accessed the machine via SSH again. After we downloaded the images from Docker Hub and run the Docker-Compose file to start the application.

<br />
<br />
<p align="center" ><img src="/images/workflow_docker.png" width="750"></p>
 <br />
 <br />
 
