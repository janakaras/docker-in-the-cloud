# Cloud Computing Project: 
## Deployment of a Docker-based application in the cloud


## Contents

1. [ Problem description ](#desc)  
1.1 [ Status quo ](#status)  
1.2 [ Goal ](#goal)

2. [ Implementation ](#impl)  
2.1 [ GitHub and GitHub Actions ](#git)  
2.2 [ Terraform and AWS ](#terraform)  
2.3 [ Docker ](#docker)  
2.4 [ Deployment of application on EC2 instance ](#ec2_deployment)  
2.5 [ Deployment of application on EC2 instance  - Alternative ](#ec2_deployment_alt)  

## 1. Problem description <a name="desc"></a>

### 1.1 Status quo <a name="status"></a>

The starting point of the project will be a Docker-based web application for managing apartments that the students of the Software Engineering Master developed in 
the last semester. The application can be cloned from the unibz instance of GitLab:  
https://gitlab.inf.unibz.it/Jana.Karas/cloud-computing-project  

The core part of the application consists of three docker containers that contain flask apps fulfilling the following services:  
* Apartments: Add new apartments or remove apartments that are no longer offered.
* Search: Search for free apartments in a given timeframe.
* Reserve: Make or cancel reservations for free apartments.

The containers communicate via a RabbitMQ Message Queue, which resides in another container. Furthermore, the application has a Portainer container 
for managing the containers and a Consul container for Service Registry.

### 1.2 Goal <a name="goal"></a>

 The ultimate goal is to deploy the application in the cloud. The deployment should be detached from any local machines restrictions. 
 Several AWS cloud options will be evaluated like EC2, Lambda, ECS or Elastic Beanstalk.
 
## 2. Implementation <a name="impl"></a>
 
### 2.1 GitHub and GitHub Actions <a name="git"></a>
 
 The whole existing Docker-based web application is moved to [GitHub](https://github.com/). The online software development platform based on the open-source version control software Git is suited well for us to work on the project in a team and provides a base for deploying our software online.  
 GitHub includes the continuous integration and continuous delivery (CI/CD) platform [GitHub Actions](https://github.com/features/actions). With GitHub Actions, we will be able to design workflows which will be triggered by for example changes in the application's code that are pushed to GitHub. With GitHub Actions, we will be able to automatically deploy our application in the cloud without any manual steps necessary in the course of the workflow.  
 
 In a first step, we create a workflow in GitHub Actions that prints "Hello World" after a push event in the repository.
 
### 2.2 Terraform and AWS <a name="terraform"></a>

In a next step, we want to set up a cloud infrastructure where we can deploy our software. For this we want to use the open source infrastructure as code (IaC) software tool HashiCorp's [Terraform](https://www.terraform.io/) that lets you  build, change, and version public cloud infrastructure such as for example [AWS](https://aws.amazon.com/). On AWS, we want to use in a first set up an Amazon Elastic Compute Cloud ([Amazon EC2](https://aws.amazon.com/ec2/)) instance to deploy our application.  AWS provides a great amount of EC2 instances with different configurations of CPU, memory, storage and networking resources. With the AWS Free Tier, we have some options to try our setup on Linux t2.micro instances for free.  
In a GitHub Actions workflow, we want to use Terraform to start an EC2 instance where we can deploy our application later. For this, we set up a file 'main.yml' in the GitHub Actions workflows and a file 'main.tf' in the home directory of our GitHub project. In the workflow, the Terraform CLI is installed and configured. Now, Terraform uses the configuration details in the 'main.tf' to install and start an EC2 instance currently in the course's Lab's account. For now, this instance is not doing anything.  
The next goal is to upload our application and run it on the created EC2 instance.

### 2.3 Docker <a name="docker"></a>

The application is composed of Docker containers. [Docker](https://www.docker.com/) is a software framework for building, running, and managing containers on servers and the cloud. A Docker container image is a package of software that includes everything needed to run an application. Our application is made of several containers which can be run by the tool [Docker Compose](https://docs.docker.com/compose/).  
To run our application on AWS, we need to install Docker and Docker Compose on the EC2 instance. We start to do the installation locally via Secure Socket Shell (SSH). From our running EC2 instance we can download the private key and get the public DNS name and username, so we can connect to the instance in a terminal from a local machine. With some shell commands, we can install Docker and Docker Compose on the EC2 instance.

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

