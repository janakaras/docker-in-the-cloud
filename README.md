# Cloud Computing Project: 
## Deployment of a Docker-based application in the cloud


## Contents

1. [ Problem description ](#desc)  
    1.1. [ Starting Point ](#start)  
    1.2. [ Goal ](#goal)

2. [ Basic Structure and Tools ](#basic_tools)  
    2.1. [ Basic Structure ](#basic_structure)  
    2.2. [ Docker ](#docker)  
    2.3. [ GitHub Actions ](#github_actions)  
    2.4. [ Terraform ](#terraform)  
    2.5. [ AWS ](#aws)  

3. [ Final Implementation ](#impl)  
    3.1. [ Solution 1 - zip ](#zip)  
    3.2. [ Solution 2 - Docker Hub ](#docker_hub)  
    3.3. [ Full Project Workflow Overview  ](#overall) 

4. [ Challenges in the Progress ](#challenges)  
    4.1. [ Accessing the AWS account ](#challenges_aws)  
    4.2. [ Terraform State ](#challenges_terraform)  
    4.3. [ Accessing the EC2 machine to deploy the app ](#challenges_ssh)  
    4.4. [ Accessing the application in the browser ](#challenges_security_rules)

5. [ Discussion ](#discussion)  
    5.1. [ Comparison of solutions ](#comparison)  
    5.2. [ Improvements for the solutions ](#improvements)  
    5.3. [ Possible next steps for the project ](#next_steps)  


6. [ Conclusion ](#conclusion)  

## 1. Problem description <a name="desc"></a>

### 1.1. Starting Point <a name="start"></a>

The starting point of the project was a Docker-based web application for managing apartments that the students of the Software Engineering Master developed in 
the semester before (WS2021). The original application can be cloned from the unibz instance of GitLab:  
https://gitlab.inf.unibz.it/Jana.Karas/cloud-computing-project. For starting the application locally, docker has to be installed on the machine. 

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

Add the following paths to the base URL: 

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


### 1.2. Goal <a name="goal"></a>

The goal is to automatically deploy our web application in the cloud. This will be done in a Github CI/CD-Pipeline: All included steps such as setting up the infrastructure, uploading the application to the cloud environment, starting the app in the cloud, etc. will be automated.
 
## 2. Basic Structure and Tools <a name="basic_tools"></a>

### 2.1. Basic Structure <a name="basic_structure"></a>

We moved the whole existing Docker-based web application to GitHub, so we could work together on the project as a team. Also, GitHub provided the general framework to set up automated workflows to deploy our app in the cloud with GitHub Actions. In such a workflow, we used Terraform to set up the cloud infrastructure and created a virtual machine on the cloud platform AWS where we could deploy our web app by using Docker to upload and run the application.

<br />
<br />
<p align="center" ><img src="/images/basic_idea.png" width="500"></p>
<br />
<br />

### 2.2. Docker <a name="docker"></a>

The application is composed of Docker containers. [Docker](https://www.docker.com/) is a software framework for building, running, and managing containers on servers and the cloud. A Docker container image is a package of software that includes everything needed to run an application. Our application is made of several containers which can be run by the tool [Docker Compose](https://docs.docker.com/compose/).  
Both Docker and Docker Compose needed to be installed on the virtual machine in the cloud.  
To deliver the images of our application to the cloud, we used the option to save them on [Docker Hub](https://hub.docker.com/). Docker Hub is a hosted repository service provided by Docker for finding and sharing container images with your team.

### 2.3. GitHub Actions <a name="github_actions"></a>

We used [GitHub](https://github.com/), an online software development platform based on the open-source version control software Git, to collaborate on the project together. GitHub includes the continuous integration and continuous delivery (CI/CD) platform [GitHub Actions](https://github.com/features/actions). GitHub Actions enables you to design workflows that will be started based on certain triggers such as a push to a certain branch in the repository. With GitHub Actions, we were able to automatically deploy our application in the cloud without any manual steps necessary in the course of the workflow.  
There are a lot of publicly available GitHub Actions. We used one of them to set up our infrastructure to deploy the application in the cloud.

### 2.4. Terraform <a name="terraform"></a>

To set up the cloud infrastructure, we used the open source infrastructure as a code (IaaC) software tool HashiCorp's [Terraform](https://www.terraform.io/) that lets you  build, change, and version public cloud infrastructure. In Terraform, we could configure the virtual machine in the cloud suited to our needs.  
We used the SaaS platform [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) to save secret configuration variables for security reasons. Also, Terraform Cloud lets you save the state of your infrastructure remotely so the system knows whether to create or update the configured cloud infrastructure.

### 2.5. AWS <a name="aws"></a>

To host our application, we used the Free Tier offerings of [AWS](https://aws.amazon.com/) (Amazon Web Services). AWS is a cloud computing platform provided by Amazon that includes a mixture of infrastructure as a service (IaaS), platform as a service (PaaS) and packaged software as a service (SaaS) offerings. Among the big offering of AWS, the cloud platform provides the usage of virtual machines called Amazon Elastic Compute Cloud ([Amazon EC2](https://aws.amazon.com/ec2/)). We used these EC2 instances to deploy our application on AWS. AWS provides a great amount of EC2 instances with different configurations of CPU, memory, storage and networking resources. With the AWS Free Tier, we had some options to try our setup on Linux t2.micro instances for free.  


### 3. Final Implementation <a name="impl"></a>

#### 3.1. Solution 1 - zip <a name="zip"></a>

Both of our final solutions follow the basic described structure:  
Following a trigger a GitHub Actions workflow starts. In the workflow with the help of Terraform an EC2 instance is created or if already existing updated. This will be decided by the remote state file in Terraform Cloud. In Terraform the configuration of the EC2 instance is defined. The correct security groups are defined and assigned, an Elastic IP which was created in the AWS account is assigned and in the User Data of the configuartion implementation Docker and Docker-Compose are installed in the EC2 instance.
After the creation of the EC2 instance we worked out two solutions to upload the application to the cloud. In the first solution the first step was to access the instance from the wokflow. This was done via SSH and the predefined Elastic IP. To upload the application we used in our first solution the from GitHub provided .zip link to bring the whole application in the cloud. There we unzipped the folder and ran the on the instance installed docker-compose up to start the application.

<br />
<br />
<p align="center" ><img src="/images/workflow_zip.png" width="750"></p>
<br />
<br />

#### 3.2. Solution 2 - Docker Hub <a name="docker_hub"></a>

In the second solution we followed a different approach to upload the application to the cloud. In a first workflow the images of the Docker containers got published to Docker Hub. After that the EC2 instance got created like in the first described solution. The third step was to access the images from the running EC2 machine. Here we first used the linux "scp" command to copy only the docker-compose.yml file and the database files (instead of the whole application) and then accessed the machine via SSH again. Inside the machine, we downloaded the images from Docker Hub and ran the previously copied Docker-Compose file to start the application.

<br />
<br />
<p align="center" ><img src="/images/workflow_docker.png" width="750"></p>
 <br />
 <br />
 
 
#### 3.3. Full Project Workflow Overview <a name="overall"></a>


In the final version of the project it has been decided that the **Solution 2** (the Dockerhub image-based approach) will be used as the main method to deploy our container-based application to the EC2 machine. This has been done for improved image reusablitily and solution transparency reasons. Therefore, commiting the main branch now triggers **Workflow (1)** *(see image below)* which is responsible for image creation and publishment to Dockerhub, which in its turn triggers **Workflow (2)** that is responsible for setting up the EC2 Infrastructure using Terraform. Finally, after **Workflow (2)** has finished, **Workflow (3)** accesses the EC2 machine and composes the images fetched from Dockerhub. 

<br />
<br />
<p align="center" ><img src="/images/workflow_whole.png" width="900"></p>
<br />
<br />

As an alternative, we leave the option to manually trigger **Workflow (4)**, which would access the EC2 machine and fetch the application in the .zip format. This coresponds to the **Solution 1**. In this case, we assume that the EC2 machine is already running and no setup action is needed. 

Lastly, a manual workflow designed for shutting down the infrastructure created by Terraform is defined (**Workflow (5)**). Running this workflow would destroy the EC2 machine that is running, which is useful in case the machine is no longer needed, costs too much or if sensitive content has been published to the server and one wants to remove it as fast as possible.
 
 
### 4. Challenges in the Progress <a name="challenges"></a>

In the course of the project we were facing some challenges:

#### 4.1. Accessing the AWS account <a name="challenges_aws"></a>

We started with an AWS Lab account, which comes with a different set of access keys every time you start it. This required a manual update of these access keys in our code every time. To have constant access keys, we needed to switch to a normal AWS account. During that process we noticed that hard-coding the access keys in the code is a security problem. To fix this, we saved the AWS access keys remotely in Terraform Cloud. 

#### 4.2. Terraform State <a name="challenges_terraform"></a>

When we managed to set up the cloud infrastructure and run the application on it, we discovered that another run of the workflow while the instance of the run before was still running lead to the creation of a second EC2 instance, although the already running instance was supposed to be updated. We could fix this problem by saving the state of the infrastructure remotely in Terraform Cloud, so it would consider the existing state of the infrastructure during a new run of the workflow.

#### 4.3. Accessing the EC2 machine to deploy the app <a name="challenges_ssh"></a>

To access the EC2 instance in the workflow, we explored different solutions. When starting the instance, the field "user_data" can be used to execute commands inside the EC2 machine. This, however, is only executed when the instance is newly created. Therefore, we use user_data only for the basic initialization of the machine (installing docker and docker-compose). For updating the application in case of a change we needed to SSH into the machine. To use the SSH command in our CI/CD pipeline, we needed a fixed IP address and Private key of the EC2 machine. In the beginning, when we worked with the Labs account, this wasn't possible. However, when we switched to the private AWS account, we could download a fixed Private key and store it as a Github secret. For creating a constant IP adress, we used the AWS Elastic IP service. This allocates a fixed IP address to the AWS account. We then assign this IP address to our EC2 instance in our Terraform configuration file. The only issue that needs to be considered when using Elastic IP is that it costs some money if it's currently not assigned to a running EC2 instance. 

#### 4.4. Accessing the application in the browser <a name="challenges_security_rules"></a>

After deploying the application, we needed to open the correct port (in this case 5004) of the EC2 machine to be able to access the web application in the browser. For solving this, we added a security group which opens port 5004 to our Terraform configuration file and attached it to our EC2 instance. 

### 5. Discussion <a name="discussion"></a>

#### 5.1. Motivation of design decisions

Working in the cloud comes with a great amount of services offered, where you have to choose which ones you want to use and combine. There are usually a lot of different solutions possible and one needs to decide which solution works best in the single case. Parameters to base the decision on could be pricing, privacy, computing capacity, availbility, easyness to manage, etc.  
For us it was first of all important to use free options which are easy to work with, so we could get a comfortable introduction to cloud computing and get an impression of what is possible in general. Second, we wanted to experiment on how to deploy a docker-compose app and noticed that many services (e.g. Lambda) only support deploying a single container and not a docker-compose application. Therefore, we needed the flexibility of the EC2 service. Finally, we wanted to create a fully automated deployment, which is why we used a Github Actions and Terraform. 

#### 5.2. Comparison of solutions <a name="comparison"></a>
We developed two solutions to deploy our web application in the cloud which both have some advantages in disadvantages.  

##### .zip solution:
* Advantages:
    * Higher security of privacy, since the code isn't published to an extra platform
    * Less complexety, so mantaining and debugging is easier
* Disadvantages:
    * .zip link is a black box

##### Docker solution:
* Advantages:
    * More reusable, images can be used for other purposes
    * More flexible
* Disadvantages:
    * More possible stations for attacking
    * Another platform to deploy

#### 5.3. Improvements for the solutions <a name="improvements"></a>
Our solution is based on a number of virtualisation layers and steps: The Github runner in our CI/CD-pipeline already is a virtual machine. Inside the Github Runner, we connect to the Terraform Remote Backend and in there create an EC2 machine. Finally, inside this machine, we are using several docker containers that are built with docker-compose. 
This structure allows for automation, however, it is also a bit error-prone due to the various virtual machines and containers that need to play together to make the solution work. 
An idea to simplify this structure a little bit is to separate the docker containers. One container could reside either in an EC2 instance, or other services such as Lambda, the Elastic Container Service or Elastic Beanstalk could be explored. These services already have options to deploy single containers, whereas deploying a whole docker-compose app is rather complicated if not impossible. Additionally, the database could then be moved to a database service. However, like this, docker-compose would not be suitable for building the app anymore and additionally, the Rabbit MQ message queue would have to be replaced e.g. by an aws message queue. 

#### 5.4. Possible next steps for the project <a name="next_steps"></a>
A possible next step could be to add Autoscaling and a Load Balancer to the current infrastructure. With Autoscaling, copies of the instance(s) would be created if the current load is too high for one single instance. A Load Balancer would then distribute the traffic between the instance copies. The Elastic IP would be assigned to the Load Balancer instead of the EC2 instance. On receiving a request to the IP address, the Load Balancer would then decide which instance the request is directed to. Key requirement for this step would be to have a global database service that all instances can have access to: In the current solution, every copy of the instance would have it's own local database, which is not desirable for the application. Another aspect that should be considered is that updating the application would require (from our current understanding) to shut down all the copies and power them up again afterwards. This could lead to the serivce being unavailable for a few short minutes.

### 6. Conclusion <a name="conclusion"></a>
During the course of this project we have successfully implemented a mechanism that deploys our docker-compose application to an EC2 instance. The solution includes a CI/CD pipeline, the infrastructure creation using Terraform, two possibilities for deploying and running the app on the EC2 instance and a possibility to shutdown the infrastructure automatically. In general we noticed that the number of services supporting the (easy) deployment of an app packaged in a single container is much higher than the possibilities for deploying a docker-compose app. Therefore a possibly better solution could be to deploy each container separately using a service of choice and reimplement the communication in a way that suits the new infrastructure.
