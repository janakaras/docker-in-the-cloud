# Cloud Computing Project: 
## Deployment of a Docker-based application in the cloud


## Contents

1. [ Problem description ](#desc)  
1.1 [ Status quo ](#status)  
1.2 [ Goal ](#goal)

2. [ Implementation ](#impl)  

<a name="desc"></a>
## 1. Problem description

<a name="status"></a>
### 1.1 Status quo

The starting point of the project will be a Docker-based web application for managing apartments that the students of the Software Engineering Master developed in 
the last semester. The application can be cloned from the unibz instance of GitLab:  
https://gitlab.inf.unibz.it/Jana.Karas/cloud-computing-project  

The core part of the application consists of three docker containers that contain flask apps fulfilling the following services:  
* Apartments: Add new apartments or remove apartments that are no longer offered.
* Search: Search for free apartments in a given timeframe.
* Reserve: Make or cancel reservations for free apartments.

The containers communicate via a RabbitMQ Message Queue which resides in another container. Furthermore, the application has a Portainer container 
for managing the containers and a Consul container for Service Registry.

<a name="goal"></a>
### 1.2 Goal

 The ultimate goal is to deploy the application in the cloud. The deployment should be detached from any local machines restrictions. 
 Several AWS cloud options will be evaluated like EC2, Lambda, ECS or Elastic Beanstalk.
 
 <a name="impl"></a>
## 2. Implementation
1. Movement of the project to GitHub to be able to use GitHub Actions  
2. First Github Action that prints "Hello World"
3. Set up of Github Actions workflow that uses Terraform to start an EC2 machine in the AWS Lab.
4. Installation of Docker on the EC2 machine via SSH from local machine
5. Installation of Docker Compose on the EC2 machine via SSH from local machine
6. Uploading the application to the EC2 machine via SSH from local machine (Problem: ports are not working -> adjustment of security group)
7. Creation of an EC2 instance with required security rule via GitHub Actions and Terraform
8. Failing of finding a solution to use SSH in GitHub Actions to run application on EC2 machine
9. Set up of new GitHub Action to publish the single images of the application to DockerHub
10. Achievement of running the application on the EC2 machine via GitHub Actions: Usage of the "User Data" to upload the application from GitHub via .zip file link. 
Installation of Docker and Docker Compose and running of the application also via "User Data"
11. Moving from the AWS Lab to a private account
12. Problem: Consecutive runs of the workflows lead to set up of different EC2  machines, while it is supposed to refer to an already existing one 
-> Usage of remote Terraform state in Terraform cloud
13. Saving of AWS variables to Terraform cloud to avoid security issues
14. Due to the remote stage file the workflow recognizes an existing EC2 instance. 
Problem: A change in the applications code won't be transmitted to an existing EC2 instance
-> switch from .zip soution to ssh again to do the installation of the app in an extra step
15. To set up the ssh solution:
  - created a ssh key in the AWS account 
  - assigned the key to the aws instance creation in terraform 
  - updated the manual workflow to try to ssh into the machine -> not working yet
