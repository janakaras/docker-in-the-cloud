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

The starting point of the project will be a Docker-based web application for managing apartments that the students of the Software Engineering Master developed in 
the last semester. The application can be cloned from the unibz instance of GitLab:  
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

(Should we include the "Basic Idea" graphic from the presentation here?)

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


 


 
 
 # OLD
 
 
 


### 2.4 Deployment of application on EC2 instance <a name="ec2_deployment"></a>

In a first step, we try to run the application on the EC2 machine from a local machine via SSH. We manage to start our application on the EC2 instance, but the ports are not working to show the output of the app in the Browser. By adjusting the security group of the EC2 instance, we manage to connect to the ports of the instance. We adjust the configuration of the EC2 instance in the Terraform configuration in the file 'main.tf'.  
After managing to run the application on AWS accessing the instance from the local machine, we want to have the whole process managed by the GitHub Actions. In Order to do that, we need to access the instance in the workflow. The idea to use SSH to connect fails, because there seems to be no solution for getting the private key from the newly created EC2 instance.

We start to follow an alternative solution: We set up a new GitHub Action that publishes the singles images of the applications containers to Dockerhub. From there we might be able to upload the application to the EC2 machine.

In a third possible solution, we manage to upload the application by using the optional field "User Data" in the configuration part of the EC2 instance in the file 'main.tf'. We can use the .zip link, that GitHub provides, to upload the whole application's code to the EC2 machine. In the same "User Data" we install Docker and Docker Compose. After we can run the application. 

Since we have to update the AWS credentials of the currents Lab in our setup every time we want to work on the project, we move to a private AWS account.

While starting the workflow several times in a short distance, we detect that every time a new EC2 instance is created which runs parallel to the existing ones. But we want to have only one machine that is only updated when a new push occurs. To solve this, we store the Terraform state remotely in Terraform cloud. At one go we save our prior hard coded AWS variables in the Terraform cloud too and access them via a new file 'variables.tf'. Previous occurring security issues are solved by this.

Due to the remote state file, the workflow recognizes now an existing EC2 instance, so a new push doesn't create a new instance anymore. While the setup recognizes an existing instance, it can't detect a change in the applications code which is concealed by the static .zip file link in the "User Data". So a change of the application won't be applied to the running EC2 machine. One ungraceful solution could be to change the "User Data" at every push. But we decide to switch back to the SSH solution instead of using the .zip file in the "User Data".

Since we have a private AWS account we can store the now not changing AWS variables, create a SSH key in the AWS account and assign the key to the EC2 instance creation in Terraform. Also, we can set up an elastic IP in AWS which we can use for every new EC2 instance. No we can connect to the EC2 machine via SSH in the GitHub Actions workflow, upload the .zip file with the application there and run it on the machine, where we installed Docker and Docker Compose in the "User Data". 
Now we have a running solution where our application is automatically deployed on an EC2 instance.

Since having an elastic IP constantly assigned to our account is not for free, we decided to have a created instance constantly running by using the AWS Free Tier for the rest of the project.

To shut down a running instance, we set up another GitHub Action, that shuts down the EC2 machine when manually triggered.


### 2.5 Deployment of application on EC2 instance  - Alternative <a name="ec2_deployment_alt"></a>

As an alternative to the upload via the .zip link we follow our started set up, where we push the images of the single docker containers to Docker Hub via a separate GitHub Actions workflow. I a second consequent workflow we use SSH to access the EC2 machine, take the images from Docker Hub and run docker compose up to start the application on the EC2 instance.

