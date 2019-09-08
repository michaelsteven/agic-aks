# Using Ansible for a Greenfield Deployment of an Application Gateway Ingress Controller Enabled Azure Kubernetes Cluster

## Overview

### What is this?
Microsoft has made available for [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/) a Kubernetes [Ingress Controller](http://kubernetes.io/docs/user-guide/ingress/) that leverages the [Azure Application Gateway](https://azure.microsoft.com/en-us/services/application-gateway/).  More information about the Application Gateway Ingress Controller (AGIC) can be found at: https://github.com/Azure/application-gateway-kubernetes-ingress

This repository has an [Ansible](https://www.ansible.com/) folder that contains a playbook and roles needed to deploy a [greefield](https://en.wikipedia.org/wiki/Greenfield_project) AKS cluster that uses an AGIC into your Azure subscription.

### Why an Ansible deployment?
The official [Application Gateway Ingress Controler Github Repository](https://github.com/Azure/application-gateway-kubernetes-ingress) has instructions for manually deploying a greenfied AKS cluster with an AGIC.  Manual steps take time and thought, and are subject to human mistakes. The goal of this project is to automate the entire installation for consistancy and repeatability. It could also form the starting point for a larger environment deployment should you wish to clone, copy, or fork this repository.

### Why use a Docker image in the Deployment?
The docker image is used to eliminate the need to install many of the dependencies that would otherwise require a local installation.  The specific versions of software are fixed and will not change, providing consistency and portability.  

## Prerequisites
 - [Docker](https://www.docker.com/) installed
 - An understanding of [Docker](https://www.docker.com/) and [Kubernetes](https://kubernetes.io/)
 - Some [Ansible](https://www.ansible.com/)  experience is helpful
 - An [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) in your Azure Subscription to store secrets
 - An [Azure subscription](https://azure.microsoft.com/en-us/free/) with the ability to perform the following actions
    - Create Resource Groups
    - Create Service Principals
    - Create AKS Clusters
    - Permissions to write to an [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/)

NOTE: An [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) will need to exist in the subscription, and its name used in a later step when configuring the playbook variables.  In this vault, secrets resulting from the execution of the playbook will be stored for use by the playbook's roles, and for your future reference.  If a suitable vault doesn't exist for this purpose, be sure that one is created prior to running the playbook. 

## How to Use:
The ansible playbooks are intended to be ran from inside of a purpose-built docker container.

### Step 1: Clone down this Git Repository
- Change to a folder that you would like to use as your workspace
- Use the Git CLI to run the clone command:
    ```
    git clone https://github.com/michaelsteven/agic-aks
    ```

### Step 2: Build or Pull the Docker Image 
In later steps you will use the docker image to run the ansible playbook from within a docker container.  The docker image contains all of the prerequisite software and environment configuration needed to execute the playbook.

You can choose to pull down a prebuilt version of the docker image from DockerHub, or examine the Dockerfile more closely and use it to build the docker image.

- To build the docker image yourself from the dockerfile, you can run this command:
    ```
    docker build . -t michaelsteven/ansible-agic-aks:latest
    ```
- To pull down a prebuilt version of the Docker image, you can run this command:
    ```
    docker pull michaelsteven/ansible-agic-aks:latest
    ```

### Step 3: Modify variables for your subscription

By convention, the ansible playbook variables are located at 'inventories/[your environment name]/group_vars/all.yml' for a given environment (Example: inventories/dev/group_vars/all.yml).  In the future you may wish to make folders under "inventories" for other environments.

NOTE: The ansible.cfg file has a value for the "inventory" variable pre-set, resulting by default in the use of files under the 'inventories/dev' folder for inventory and variables. Should you wish to use a different inventory group, modify the variable in the ansible.cfg, or override the value by using the "env_name=" variable when running the playbook.

Varibles requiring modification:
- organization_prefix: 5 characters or less, used generated resource names.
- env_name: 10 characters or less, used in generated resource names.
- master_key_vault: An Azure Keyvault to store credentials created by the playbook.
- azure_subscription_id: Your Azure subscription identifier.
- tenant_id: Your Azure Active Directory Tenant ID.

### Step 4: Launch an instance of the docker container

1. In a terminal window, execute the following Docker command to run with an interactive terminal the container, mounting in the "ansible" folder:
    - if using a mac or unix based operating system:
        ```
        docker run -it -v /<<path to your workspace>>/agic-aks/ansible:/ansible michaelsteven/ansible-agic-aks:latest bash
        ```
    - if using Windows 10:
        - In Docker Desktop under Settings, make sure your local drive is permitted to be shared.
        - Run the mount command with the path as shown:
            ```
            docker run -it -v C:\<<path to your workspace>>\agic-aks\ansible:/ansible michaelsteven/ansible-agic-aks:latest bash
            ```
    NOTE: The volume mount path must be an absolute path. IIf successful, you should now be at a shell prompt inside the container.

2. Log into your Azure subscription from within the container
    - Inside the docker container shell, run the AZ Login command:
        ```
        az login
        ```
    - when prompted, follow the instructions presented to validate your account.

### Step 5. Run the "create-cluster" playbook
1. Inside the docker container at the shell prompt, run the "ansible-playbook" command:
    ```
    ANSIBLE_CONFIG=/ansible.cfg ansible-playbook /ansible/create-cluster.yml -vvvv
    ```
2.  Watch the command output looking for failures. Your AGIC and AKS infrastructure components should begin to be generated in a new Resource Group within your Azure subscription.

Note: The execution of this playbook may take a while to get right.  Whenever possible, the ansible roles that make up the playbook have been made omnipotent, however key roles are not currently.  Prior to re-executing, you will need to delete the Resource Group created by the previous execution.

### Step 6. Local Docker Container Cleanup
WARNING: Because the docker image instance was used to authenticate with your credentials and a new service principal was created, it is especially important to stop and remove the container instance to destroy any files that may contain sensitive information.

1. Escape out of the running container by using the exit command.  This should also terminate the running instance.

2. Remove the stopped docker container.
    - Find and view the stopped container using this command:
        ```
        docker ps -a
        ```
    - Remove the container
        ```
        docker rm <<container name>>
        ```

## Licensing
Licensed under the Apache License, Version 2.0 (the "License"); you may not use these files except in compliance with the License.  You may obtain a copy of the License at http://ww.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permission and limitations under the License.
