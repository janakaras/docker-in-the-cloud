# Cloud Computing Project: 
## Deployment of a Docker-based application in the cloud


## Contents

1. [ Problem description ](#desc)  
1.1 [ Status quo ](#status)  
1.2 [ Goal ](#goal)

2. [ Implementation ](#impl)  

## 1. Problem description <a name="desc"></a>

### 1.1 Status quo <a name="status"></a>

The starting point of the project will be a Docker-based web application for managing apartments that the students of the Software Engineering Master developed in 
the last semester. The application can be cloned from the unibz instance of GitLab:  
https://gitlab.inf.unibz.it/Jana.Karas/cloud-computing-project  

The core part of the application consists of three docker containers that contain flask apps fulfilling the following services:  
* Apartments: Add new apartments or remove apartments that are no longer offered.
* Search: Search for free apartments in a given timeframe.
* Reserve: Make or cancel reservations for free apartments.

The containers communicate via a RabbitMQ Message Queue which resides in another container. Furthermore, the application has a Portainer container 
for managing the containers and a Consul container for Service Registry.

### 1.2 Goal <a name="goal"></a>

 The ultimate goal is to deploy the application in the cloud. The deployment should be detached from any local machines restrictions. 
 Several AWS cloud options will be evaluated like EC2, Lambda, ECS or Elastic Beanstalk.
 
## 2. Implementation <a name="impl"></a>
 
### 2.1. GitHub and GitHub Actions <a name="git"></a>
 
 The whole existing Docker-based web application is moved to [GitHub](https://github.com/). The online software development platform based on the open-source version control software Git is suited well for us to work on the project in a team and provides a base for deploying our software online.  
 GitHub includes the continuous integration and continuous delivery (CI/CD) platform [GitHub Actions](https://github.com/features/actions). With GitHub Actions we will be able to design workflows which will be triggered by for example changes in the applications code that are pushed to GitHub. With GitHub Actions we will be able to automatically deploy our application in the cloud without any manual steps necessary in the course of the workflow.  
 
 In a first step we create a workflow in GitHub Actions that prints "Hello World" after a push event in the repository.
 
### 2.2. Terraform and AWS <a name="terraform"></a>

In a next step we want to set up a cloud infrastructure where we can deploy our software. For this we want to use the open source infrastructure as code (IaC) software tool HashiCorp's [Terraform](https://www.terraform.io/) that let's you  build, change, and version public cloud infrastructure such as for example [AWS](https://aws.amazon.com/). On AWS we want to use in a first set up an Amazon Elastic Compute Cloud ([Amazon EC2](https://aws.amazon.com/ec2/)) instance.  AWS provides a great amount of EC2 instances with different configurations of CPU, memory, storage and networking resources. With the AWS Free Tier we have some options to try our setup on Linux t2.micro instances for free.  
In a GitHub Actions workflow we want to use Terraform to start an EC2 instance where we can deploy our application later. For this we set up a file 'main.yml' in the GitHub Actions workflows and a file 'main.tf' in the home directory of our GitHub project. In the workflow the Terraform CLI is installed and configured. Now terraform uses the configuration details in the 'main.tf' to install and start an EC2 instance currently in the course's Lab's account. For now this instance is not doing anything.  
The next goal is to upload our application and run it on the created EC2 instance.

### 2.2. Docker <a name="docker"></a>

The application is composed of Docker containers. [Docker](https://www.docker.com/) is a software framework for building, running, and managing containers on servers and the cloud. A Docker container image is a package of software that includes everything needed to run an application. Our application is made of several containers which can be run by the tool [Docker Compose](https://docs.docker.com/compose/).  
To run our application on AWS we need to install Docker and Docker Compose on the EC2 instance. We start to do the installation locally via Secure Socket Shell (SSH). From our runnig EC2 instance we can download the private key and get the public DNS name and user name so we can connect to the instance from a terminal from a local machine. With some shell commands we can install Docker and Docker Compose on the EC2 instance.

### 2.2. Deployment of application on EC2 instance <a name="ec2_deployment"></a>

In a frirst step we try to run the application on the EC2 machine from a local machine via SSH. We manage to start our application on the EC2 instance, but the ports are not working to show the output of the app in the Browser. By adjusting the security group of the EC2 instance we manage to connect to the ports of the instance. We adjust the configuration of the EC2 instance in the Terraform configuration in the file 'main.tf'.


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
