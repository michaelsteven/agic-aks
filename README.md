# Using Ansible for a Greenfield Deployment of an Application Gateway Ingress Controller Enabled Azure Kubernetes Cluster

## Overview

### What is this?
Microsoft has made available for managed Azure Kubernetes (AKS) clusters an Ingress Controller that leverages the Application Gateway.  More information about the Application Gateway Ingress Controller (AGIC) can be found here: xxxx

This repository has an ansible folder that contains a playbook and roles needed to deploy a greefield AKS cluster that uses an AGIC into your Azure subscription.

### Why an Ansible deployment?
There are already instructions available for manually deploying a greenfied AKS cluster with an AGIC.  The manual steps take time and thought, and may be hard for some to follow. The goal of this project is to automate the entire installation for consistancy and repeatability. It could also form the starting point for a larger enviornment deployment should you wish to clone, copy, or fork this repository.

### Why use a Docker image in the Deployment?
The docker image is used to elimate the need to install many of the dependencies that would otherwise require a local installation.  The specific versions of software are fixed and will not change, providing consistancy and portability.  

## Prerequisites
 - Docker. For information on installing docker, visit: xxxx  
 - An understanding of Docker and Kubernetes
 - Some Ansible experience is helpful
 - A Keyvault in Azure to store secrets
 - An Azure subscription with the ability to perform the following actions
    - Create Resource Groups
    - Create Service Principals
    - Create AKS Clusters
    - Permissions to write to an Azure Keyvault

NOTE: An Azure Keyvault will need to exist in the subscription, and it's name used in a later step when configuring the playbook variables.  In this vault, secrets resulting from the exeuction of the playbook will be stored for use by the playbook's roles, and for your future reference.  If a suitable vault doesn't exist for this purpose, be sure that one is created prior to running the playbook. 

## How to Use:
The ansible playbooks are intended to be ran from inside of a purpose-built docker container.

### Step 1: Clone down this Git Repository
- Change to a folder that you would like to use as your workspace
- Use the Git CLI to run the clone command:
    ```
    git clone https://github.com/michaelsteven/agic-aks
    ```

### Step 2: Build or Pull the Docker Image 
In later steps you use the docker image run the ansible playbook from within a docker container.  The docker image contains all of the prerequisite software and environment configuration needed to execute the playbook.

You can choose to pull down a prebuilt verson of the docker image from DockerHub, or examine the Dockerfile more closely and use it to build the docker image.

- To build the docker image yourself from the dockerfile, you can run this command:
    ```
    docker build . -t michaelsteven/ansible-agic-aks:latest
    ```
- To pull down a prebuilt version of the Docker image, you can run this command:
    ```
    docker pull michaelsteven/ansible-agic-aks:latest
    ```

### Step 3: Modify variables for your subscription

By convention, the ansible playbook variables are located at 'inventories/[your environnment name]/group_vars/all.yml' for a given environment (Example: inventories/dev/group_vars/all.yml).  In the future you may wish to make folders under "inventories" for other evironments

NOTE: The ansible.cfg file has a value for the "inventory" variable pre-set, resulting by default in the use of files under the 'inventories/dev' folder for inventory and varibles. Should you wish to use a different inventory group, modify the variable in the ansible.cfg, or override the value by using the "env_name=" variable when running the playbook.

Varibles requiring modification:
- organization_prefix: 5 characters or less, used generated resource names.
- env_name: 10 characters or less, used in generated resource names.
- master_key_vault: An Azure Keyvault to store credentials created by the playbook.
- azure_subscription_id: Your Azure subscription identifier.
- tenant_id: Your Azure Active Directory Tenant ID.

### Step 4: Launch an instance of the docker container

1. In a new terminal session, execute the following Docker command to run with an interactive terminal the container, mounting in the "ansible" folder:
    ```
    docker run -it -v /Users/michaelhepfer/workspaces/michaelsteven/agic-aks/ansible:/ansible michaelsteven/ansible-agic-aks:latest bash
    ```
    You should now be at a shell prompt inside the container.

2. Change into the ansible folder in the containter
    ```
    cd /ansible
    ```
3. Log into your Azure subscription from within the container
    - Inside the docker container shell, run the AZ Login command:
        ```
        az login <subscription id>
        ```
    - when prompted, follow the instructions presented to validate your account.

### Step 5. Run the "create-cluster" playbook
1. Inside the docker container at the shell prompt, run the "ansible-playbook" command: 
    ```
    ansible-playbook create-cluster.yml -vvvv
    ```
2.  Watch the command output looking for failures. Your AGIC and AKS infrastructure components should begin to be generated in a new Resource Group within your Azure subscription.

Note: The execution of this playbook may take a while to get right.  Whenever possible, the ansible roles that make up the playbook have been made omnipotent, however key roles are not currently.  Prior to re-executing, you will need to delete the Resource Group created by the prevous execution.

### Step 6. Local Docker Container Cleanup
WARNING: Because the docker image instance was used to authenticate with your credentials and a new service princiapl was created, it is especially important to stop and remove the container instance to destroy any files that may contain sensitive information.

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

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either exress or implied.  See the License for the specific language governing permission and limitations under the License.
